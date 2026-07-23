//! `search_engine` — Phase 10 Search, Indexing & Content Discovery Engine.

pub mod bridge;
pub mod collection_engine;
pub mod duplicate;
pub mod engine;
pub mod error;
pub mod events;
pub mod favorites_index;
pub mod filter_engine;
pub mod history_index;
pub mod index_engine;
pub mod metadata_index;
pub mod models;
pub mod persistence;

pub use error::SearchEngineError;
pub use models::*;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
