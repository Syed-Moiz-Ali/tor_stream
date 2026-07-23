//! Domain models for reliability engine.

use serde::{Deserialize, Serialize};

/// Persisted session snapshot model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionSnapshot {
    pub torrent_id: u64,
    pub info_hash: String,
    pub magnet_uri: Option<String>,
    pub file_index: u32,
    pub playback_position_bytes: u64,
    pub total_bytes: u64,
    pub selected_audio_track: u32,
    pub selected_subtitle_track: u32,
    pub playback_speed: f32,
    pub is_playing: bool,
    pub last_active_timestamp_ms: i64,
}

/// System health status report.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthStatus {
    pub is_healthy: bool,
    pub available_storage_bytes: u64,
    pub storage_warning: bool,
    pub available_ram_mb: u32,
    pub is_database_ok: bool,
    pub is_network_connected: bool,
    pub active_torrents_count: usize,
}

/// Storage verification report.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StorageReport {
    pub total_space_bytes: u64,
    pub free_space_bytes: u64,
    pub cache_size_bytes: u64,
    pub corrupted_pieces_repaired: u32,
    pub database_vacuumed: bool,
}
