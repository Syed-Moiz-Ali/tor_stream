//! `performance_engine` — Phase 6 Performance Optimization & Streaming Intelligence.

pub mod benchmark;
pub mod bridge;
pub mod cache_optimizer;
pub mod disk_optimizer;
pub mod error;
pub mod memory;
pub mod metrics;
pub mod models;
pub mod network_optimizer;
pub mod piece_optimizer;
pub mod profiler;

pub use error::PerformanceError;
pub use models::*;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
