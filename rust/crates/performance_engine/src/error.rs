//! Error types for performance engine.

use thiserror::Error;

/// Performance engine errors.
#[derive(Debug, Error)]
pub enum PerformanceError {
    #[error("Object pool exhausted for buffer size {requested_bytes}")]
    BufferPoolExhausted { requested_bytes: usize },

    #[error("Benchmark failed: {reason}")]
    BenchmarkFailed { reason: String },

    #[error("Profiler error: {reason}")]
    ProfilerError { reason: String },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Engine error: {0}")]
    Engine(String),
}

pub type Result<T> = std::result::Result<T, PerformanceError>;
