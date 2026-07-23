//! Domain models for download manager and media library.

use serde::{Deserialize, Serialize};

/// Priority tier for queued downloads.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub enum QueuePriority {
    Lowest = 0,
    Low = 1,
    Normal = 2,
    High = 3,
    Highest = 4,
}

/// Execution state of a download task.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DownloadState {
    Queued,
    Downloading,
    Paused,
    Completed,
    Failed,
    Cancelled,
}

/// Download Task representation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadTask {
    pub id: u64,
    pub torrent_id: u64,
    pub title: String,
    pub save_path: String,
    pub total_bytes: u64,
    pub downloaded_bytes: u64,
    pub progress: f32,
    pub download_speed_bps: u64,
    pub priority: QueuePriority,
    pub state: DownloadState,
    pub added_at_ms: i64,
}

/// Organized media category.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MediaCategory {
    Movie,
    TvShow,
    Anime,
    Documentary,
    MusicVideo,
    Other,
}

/// Media Library item representation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LibraryItem {
    pub id: u64,
    pub torrent_id: u64,
    pub title: String,
    pub category: MediaCategory,
    pub primary_file_index: u32,
    pub total_bytes: u64,
    pub artwork_path: Option<String>,
    pub is_favorite: bool,
    pub date_added_ms: i64,
}

/// Continue Watching item metadata.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContinueWatchingItem {
    pub id: u64,
    pub torrent_id: u64,
    pub file_index: u32,
    pub title: String,
    pub artwork_path: Option<String>,
    pub position_ms: u64,
    pub duration_ms: u64,
    pub progress_pct: f32,
    pub last_played_ms: i64,
}

/// Bandwidth control settings.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BandwidthSettings {
    pub download_limit_bps: u64,
    pub upload_limit_bps: u64,
    pub wifi_only: bool,
    pub max_active_downloads: usize,
}

impl Default for BandwidthSettings {
    fn default() -> Self {
        Self {
            download_limit_bps: 0, // unlimited
            upload_limit_bps: 0,
            wifi_only: false,
            max_active_downloads: 3,
        }
    }
}
