//! Error types for download manager and media library.

use thiserror::Error;

/// Download manager and library errors.
#[derive(Debug, Error)]
pub enum DownloadManagerError {
    #[error("Download task {id} not found")]
    TaskNotFound { id: u64 },

    #[error("Library item {id} not found")]
    LibraryItemNotFound { id: u64 },

    #[error("Storage location {path} is invalid or non-writable")]
    InvalidStorageLocation { path: String },

    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, DownloadManagerError>;
