//! Stream statistics collector.

use std::sync::Arc;
use tokio::sync::RwLock;

use crate::models::{PlaybackState, StreamStatistics};

/// Real-time stream statistics collector.
#[derive(Clone)]
pub struct StreamStatisticsCollector {
    torrent_id: u64,
    file_index: u32,
    stats: Arc<RwLock<InternalStats>>,
}

struct InternalStats {
    playback_state: PlaybackState,
    bitrate_bps: u64,
    download_speed_bps: u64,
    startup_latency_ms: u64,
    buffer_stalls: u32,
    bytes_streamed: u64,
    read_ahead_seconds: f32,
}

impl StreamStatisticsCollector {
    pub fn new(torrent_id: u64, file_index: u32) -> Self {
        Self {
            torrent_id,
            file_index,
            stats: Arc::new(RwLock::new(InternalStats {
                playback_state: PlaybackState::Idle,
                bitrate_bps: 0,
                download_speed_bps: 0,
                startup_latency_ms: 0,
                buffer_stalls: 0,
                bytes_streamed: 0,
                read_ahead_seconds: 0.0,
            })),
        }
    }

    pub async fn record_state(&self, state: PlaybackState) {
        self.stats.write().await.playback_state = state;
    }

    pub async fn record_startup_latency(&self, latency_ms: u64) {
        self.stats.write().await.startup_latency_ms = latency_ms;
    }

    pub async fn record_stall(&self) {
        self.stats.write().await.buffer_stalls += 1;
    }

    pub async fn record_bytes_read(&self, bytes: u64) {
        self.stats.write().await.bytes_streamed += bytes;
    }

    pub async fn update_speeds(&self, download_bps: u64, bitrate_bps: u64, read_ahead_secs: f32) {
        let mut guard = self.stats.write().await;
        guard.download_speed_bps = download_bps;
        guard.bitrate_bps = bitrate_bps;
        guard.read_ahead_seconds = read_ahead_secs;
    }

    pub async fn get(&self) -> StreamStatistics {
        let guard = self.stats.read().await;
        StreamStatistics {
            torrent_id: self.torrent_id,
            file_index: self.file_index,
            playback_state: guard.playback_state,
            current_bitrate_bps: guard.bitrate_bps,
            download_speed_bps: guard.download_speed_bps,
            startup_latency_ms: guard.startup_latency_ms,
            total_buffer_stalls: guard.buffer_stalls,
            total_bytes_streamed: guard.bytes_streamed,
            read_ahead_seconds: guard.read_ahead_seconds,
        }
    }
}
