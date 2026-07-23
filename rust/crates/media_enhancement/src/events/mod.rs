//! Event definitions for media enhancement engine.

use serde::{Deserialize, Serialize};

/// Strongly typed media enhancement events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MediaEnhancementEvent {
    /// Subtitle track changed or adjusted.
    SubtitleChanged { track_index: u32, delay_ms: i64 },
    /// Audio track changed or adjusted.
    AudioTrackChanged { track_index: u32, delay_ms: i64 },
    /// Chapters parsed for container.
    ChaptersParsed { total_chapters: usize },
    /// Thumbnails generated.
    ThumbnailsReady { total_thumbnails: usize },
}
