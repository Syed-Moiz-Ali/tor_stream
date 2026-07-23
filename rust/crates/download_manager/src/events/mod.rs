//! Event definitions for download manager and media library.

use serde::{Deserialize, Serialize};
use crate::models::DownloadTask;

/// Strongly typed download and library events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DownloadEvent {
    /// Download task started.
    DownloadStarted { task: DownloadTask },
    /// Download progress update.
    DownloadProgress { id: u64, downloaded_bytes: u64, speed_bps: u64, progress: f32 },
    /// Download task paused.
    DownloadPaused { id: u64 },
    /// Download task completed.
    DownloadCompleted { id: u64 },
    /// Download task failed.
    DownloadFailed { id: u64, reason: String },
    /// Library refreshed.
    LibraryUpdated { total_items: usize },
}
