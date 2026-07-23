//! Error types for the adaptive streaming engine.

use thiserror::Error;

/// Errors emitted during stream preparation, buffering, caching, or reading.
#[derive(Debug, Error)]
pub enum StreamingError {
    #[error("Streaming engine not initialised")]
    NotInitialised,

    #[error("Stream session not found for torrent_id={torrent_id}, file_index={file_index}")]
    StreamNotFound { torrent_id: u64, file_index: u32 },

    #[error("Invalid stream seek offset {offset_bytes} for file of size {file_size}")]
    InvalidSeekOffset { offset_bytes: u64, file_size: u64 },

    #[error("Stream read timeout waiting for piece {piece_index}")]
    ReadTimeout { piece_index: u32 },

    #[error("Piece validation failed for piece {piece_index}: {reason}")]
    PieceValidationFailed { piece_index: u32, reason: String },

    #[error("Buffer stalled — insufficient bandwidth to maintain playback")]
    BufferStalled,

    #[error("Illegal playback state transition from {from} to {to}")]
    InvalidStateTransition { from: String, to: String },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, StreamingError>;
