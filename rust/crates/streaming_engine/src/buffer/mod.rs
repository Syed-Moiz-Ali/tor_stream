//! Adaptive Streaming Buffer Manager.

use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::debug;

use crate::models::BufferStatus;

/// Configurable buffering targets in bytes.
#[derive(Debug, Clone)]
pub struct BufferConfig {
    /// Default startup buffer required before starting playback (e.g. 5 MB).
    pub min_startup_bytes: u64,
    /// Default read-ahead target (e.g. 25 MB).
    pub target_read_ahead_bytes: u64,
    /// Emergency buffer threshold below which recovery triggers (e.g. 2 MB).
    pub emergency_bytes: u64,
    /// Maximum buffer limit to avoid excessive memory usage (e.g. 100 MB).
    pub max_buffer_bytes: u64,
}

impl Default for BufferConfig {
    fn default() -> Self {
        Self {
            min_startup_bytes: 5 * 1024 * 1024,
            target_read_ahead_bytes: 25 * 1024 * 1024,
            emergency_bytes: 2 * 1024 * 1024,
            max_buffer_bytes: 100 * 1024 * 1024,
        }
    }
}

/// Adaptive Buffer Manager.
#[derive(Clone)]
pub struct BufferManager {
    torrent_id: u64,
    file_index: u32,
    config: BufferConfig,
    state: Arc<RwLock<InternalBufferState>>,
}

struct InternalBufferState {
    current_position_bytes: u64,
    downloaded_ahead_bytes: u64,
    download_speed_bps: u64,
    media_bitrate_bps: u64,
    is_buffering: bool,
}

impl BufferManager {
    pub fn new(torrent_id: u64, file_index: u32, config: BufferConfig) -> Self {
        Self {
            torrent_id,
            file_index,
            config,
            state: Arc::new(RwLock::new(InternalBufferState {
                current_position_bytes: 0,
                downloaded_ahead_bytes: 0,
                download_speed_bps: 0,
                media_bitrate_bps: 2_000_000, // 2 Mbps default
                is_buffering: true,
            })),
        }
    }

    /// Update current position and downloaded bytes ahead.
    pub async fn update_progress(
        &self,
        current_pos: u64,
        buffered_ahead: u64,
        download_speed_bps: u64,
        media_bitrate_bps: u64,
    ) {
        let mut guard = self.state.write().await;
        guard.current_position_bytes = current_pos;
        guard.downloaded_ahead_bytes = buffered_ahead;
        guard.download_speed_bps = download_speed_bps;
        if media_bitrate_bps > 0 {
            guard.media_bitrate_bps = media_bitrate_bps;
        }

        let required = self.calculate_adaptive_startup(&guard);
        if guard.is_buffering && buffered_ahead >= required {
            guard.is_buffering = false;
            debug!(torrent_id = self.torrent_id, "Adaptive buffer reached startup target");
        } else if !guard.is_buffering && buffered_ahead < self.config.emergency_bytes {
            guard.is_buffering = true;
            debug!(torrent_id = self.torrent_id, "Adaptive buffer dropped below emergency threshold");
        }
    }

    /// Dynamically calculate adaptive startup buffer size based on bandwidth vs bitrate.
    fn calculate_adaptive_startup(&self, state: &InternalBufferState) -> u64 {
        if state.download_speed_bps > 0 && state.download_speed_bps >= (state.media_bitrate_bps * 12 / 10) {
            // High speed relative to bitrate: reduce startup buffer to 3 MB for faster start
            (3 * 1024 * 1024).max(self.config.emergency_bytes)
        } else if state.download_speed_bps > 0 && state.download_speed_bps < state.media_bitrate_bps {
            // Slow connection: scale startup buffer higher (up to 12 MB)
            12 * 1024 * 1024
        } else {
            self.config.min_startup_bytes
        }
    }

    /// Get current status snapshot.
    pub async fn status(&self) -> BufferStatus {
        let guard = self.state.read().await;
        let adaptive_startup = self.calculate_adaptive_startup(&guard);
        let health_ratio = if adaptive_startup > 0 {
            (guard.downloaded_ahead_bytes as f32 / adaptive_startup as f32).clamp(0.0, 2.0)
        } else {
            1.0
        };

        BufferStatus {
            torrent_id: self.torrent_id,
            file_index: self.file_index,
            current_position_bytes: guard.current_position_bytes,
            buffered_bytes: guard.downloaded_ahead_bytes,
            required_startup_bytes: adaptive_startup,
            read_ahead_bytes: self.config.target_read_ahead_bytes,
            buffer_health_ratio: health_ratio,
            is_buffering: guard.is_buffering,
            is_ready: !guard.is_buffering,
        }
    }
}
