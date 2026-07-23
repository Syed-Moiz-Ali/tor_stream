//! Error types for the torrent engine.
//!
//! All internal errors are represented as [`EngineError`]. Bridge functions
//! convert these to `anyhow::Error` before crossing the FFI boundary so that
//! Dart receives a human-readable message.

use thiserror::Error;

/// Every possible failure mode of the TorStream engine.
#[derive(Debug, Error)]
pub enum EngineError {
    // ── Lifecycle ─────────────────────────────────────────────────────────────
    #[error("Engine is not initialised — call initialize_engine() first")]
    NotInitialised,

    #[error("Engine is already initialised")]
    AlreadyInitialised,

    #[error("Engine shutdown failed: {0}")]
    ShutdownFailed(String),

    // ── Torrent operations ────────────────────────────────────────────────────
    #[error("Torrent not found: id={id}")]
    TorrentNotFound { id: u64 },

    #[error("Torrent already managed: id={id}")]
    TorrentAlreadyManaged { id: u64 },

    #[error("Invalid magnet URI: {uri}")]
    InvalidMagnet { uri: String },

    #[error("Invalid .torrent file: {reason}")]
    InvalidTorrentFile { reason: String },

    #[error("Torrent operation failed: {0}")]
    OperationFailed(String),

    #[error("Torrent metadata not yet resolved: id={id}")]
    TorrentMetadataNotResolved { id: u64 },

    // ── Session errors ────────────────────────────────────────────────────────
    #[error("Session creation failed: {0}")]
    SessionCreationFailed(String),

    #[error("Session error: {0}")]
    SessionError(String),

    // ── Storage ───────────────────────────────────────────────────────────────
    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Serialisation error: {0}")]
    Serialisation(#[from] serde_json::Error),

    // ── Configuration ─────────────────────────────────────────────────────────
    #[error("Invalid configuration: {0}")]
    InvalidConfig(String),
}

/// Convenience alias used throughout torrent_engine.
pub type Result<T> = std::result::Result<T, EngineError>;

