//! Error types for reliability engine.

use thiserror::Error;

/// Error types emitted during session persistence, verification, or recovery.
#[derive(Debug, Error)]
pub enum ReliabilityError {
    #[error("Session restoration failed: {reason}")]
    RestorationFailed { reason: String },

    #[error("Database verification failed: {reason}")]
    DatabaseIntegrityError { reason: String },

    #[error("Cache corruption detected at file {path}: {reason}")]
    CacheCorrupted { path: String, reason: String },

    #[error("Insufficient storage space: required {required_bytes} bytes, available {available_bytes} bytes")]
    InsufficientStorage { required_bytes: u64, available_bytes: u64 },

    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, ReliabilityError>;
