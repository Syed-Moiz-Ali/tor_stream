//! Unified error types for the TorStream engine.
//!
//! All internal errors are mapped to [`TorStreamError`] before crossing
//! the FFI boundary. The `ffi_bridge` crate converts these to FFI-safe
//! string representations for Dart.

use thiserror::Error;

/// The canonical error type for all TorStream operations.
#[derive(Debug, Error)]
pub enum TorStreamError {
    // ── Domain errors ─────────────────────────────────────────────────────────
    #[error("Torrent not found: {id}")]
    TorrentNotFound { id: String },

    #[error("Metadata resolution failed: {reason}")]
    MetadataFailed { reason: String },

    #[error("Stream not active for torrent={torrent_id}, file={file_index}")]
    StreamNotActive {
        torrent_id: String,
        file_index:  usize,
    },

    #[error("Invalid byte range: start={start} end={end} total={total}")]
    InvalidByteRange { start: u64, end: u64, total: u64 },

    // ── Infrastructure errors ─────────────────────────────────────────────────
    #[error("Storage error: {0}")]
    Storage(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Configuration error: {0}")]
    Config(String),

    // ── Lifecycle errors ──────────────────────────────────────────────────────
    #[error("Engine not initialized — call init_app() first")]
    NotInitialized,

    #[error("Engine already initialized")]
    AlreadyInitialized,

    // ── Catch-all ─────────────────────────────────────────────────────────────
    #[error("Internal error: {0}")]
    Internal(String),
}

/// Convenience alias — use throughout torrent_core.
pub type Result<T> = std::result::Result<T, TorStreamError>;
