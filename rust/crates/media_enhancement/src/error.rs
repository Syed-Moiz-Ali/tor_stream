//! Error types for media enhancement engine.

use thiserror::Error;

/// Media enhancement engine errors.
#[derive(Debug, Error)]
pub enum MediaEnhancementError {
    #[error("Subtitle parsing error for format {format}: {reason}")]
    SubtitleFormatError { format: String, reason: String },

    #[error("Audio track {index} unavailable")]
    AudioTrackNotFound { index: u32 },

    #[error("Chapter {index} out of bounds")]
    InvalidChapterIndex { index: usize },

    #[error("Thumbnail generation failed: {reason}")]
    ThumbnailGenerationError { reason: String },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, MediaEnhancementError>;
