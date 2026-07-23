//! `streaming_engine` — Phase 4 Production Adaptive Torrent Streaming Engine.

pub mod buffer;
pub mod cache;
pub mod error;
pub mod events;
pub mod monitor;
pub mod pipeline;
pub mod playback;
pub mod prioritizer;
pub mod reader;
pub mod scheduler;
pub mod statistics;
pub mod bridge;
pub mod models;
pub mod stream_server;

pub use error::StreamingError;
pub use events::StreamingEvent;
pub use models::*;
pub use pipeline::StreamingPipeline;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
