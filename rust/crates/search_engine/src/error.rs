//! Error types for search and indexing engine.

use thiserror::Error;

/// Search engine errors.
#[derive(Debug, Error)]
pub enum SearchEngineError {
    #[error("Collection {id} not found")]
    CollectionNotFound { id: u64 },

    #[error("Search query execution failed: {reason}")]
    QueryExecutionFailed { reason: String },

    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, SearchEngineError>;
