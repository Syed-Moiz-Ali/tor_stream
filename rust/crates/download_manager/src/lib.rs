//! `download_manager` — Phase 8 Download Manager & Media Library.

pub mod bandwidth;
pub mod bridge;
pub mod cleanup;
pub mod continue_watching;
pub mod error;
pub mod events;
pub mod favorites;
pub mod history;
pub mod library;
pub mod models;
pub mod persistence;
pub mod queue;
pub mod storage;

pub use error::DownloadManagerError;
pub use models::*;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
