//! Error types for the metadata engine.

use thiserror::Error;

/// Every possible failure mode during metadata scanning and media analysis.
#[derive(Debug, Error)]
pub enum MetadataError {
    #[error("Torrent not found or metadata incomplete: id={id}")]
    TorrentMetadataUnavailable { id: u64 },

    #[error("Corrupt or invalid metadata: {reason}")]
    CorruptMetadata { reason: String },

    #[error("Empty torrent contains no files")]
    EmptyTorrent,

    #[error("Unsupported format: {format}")]
    UnsupportedFormat { format: String },

    #[error("FFprobe analysis failed for file {path}: {reason}")]
    FfprobeError { path: String, reason: String },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Serialisation error: {0}")]
    Serialisation(#[from] serde_json::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, MetadataError>;
