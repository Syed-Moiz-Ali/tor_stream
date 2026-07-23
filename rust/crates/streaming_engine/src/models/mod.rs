//! Domain models for adaptive streaming.

use serde::{Deserialize, Serialize};

/// High-level playback state machine state.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PlaybackState {
    Idle,
    Preparing,
    Buffering,
    Ready,
    Playing,
    Paused,
    Seeking,
    Recovering,
    Completed,
    Error,
}

impl PlaybackState {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Idle => "idle",
            Self::Preparing => "preparing",
            Self::Buffering => "buffering",
            Self::Ready => "ready",
            Self::Playing => "playing",
            Self::Paused => "paused",
            Self::Seeking => "seeking",
            Self::Recovering => "recovering",
            Self::Completed => "completed",
            Self::Error => "error",
        }
    }
}

/// Piece priority level assigned by the scheduler.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub enum PiecePriority {
    /// Lowest priority / background.
    Background = 0,
    /// Sequential remaining pieces.
    Sequential = 1,
    /// Near-future window (next 10-30 seconds).
    NearFuture = 2,
    /// Immediate read-ahead window (next 5-10 seconds).
    ReadAhead = 3,
    /// Current playback read position (urgent requirement).
    PlaybackUrgent = 4,
}

/// Current status of the adaptive buffer.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BufferStatus {
    pub torrent_id: u64,
    pub file_index: u32,
    pub current_position_bytes: u64,
    pub buffered_bytes: u64,
    pub required_startup_bytes: u64,
    pub read_ahead_bytes: u64,
    pub buffer_health_ratio: f32, // 0.0 to 1.0+
    pub is_buffering: bool,
    pub is_ready: bool,
}

/// Cache status snapshot.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CacheStatus {
    pub memory_used_bytes: u64,
    pub memory_capacity_bytes: u64,
    pub pinned_pieces_count: usize,
    pub disk_used_bytes: u64,
    pub cache_hit_count: u64,
    pub cache_miss_count: u64,
    pub hit_ratio: f32,
}

/// Real-time stream performance statistics.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamStatistics {
    pub torrent_id: u64,
    pub file_index: u32,
    pub playback_state: PlaybackState,
    pub current_bitrate_bps: u64,
    pub download_speed_bps: u64,
    pub startup_latency_ms: u64,
    pub total_buffer_stalls: u32,
    pub total_bytes_streamed: u64,
    pub read_ahead_seconds: f32,
}

/// Stream URL details for HTTP byte-range server.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamUrl {
    pub url: String,
    pub content_type: String,
    pub total_length: u64,
}

