//! `metadata_engine` — Phase 3 Metadata Engine & Media Analysis.

pub mod analyzer;
pub mod artwork;
pub mod bridge;
pub mod detector;
pub mod error;
pub mod events;
pub mod ffprobe;
pub mod media;
pub mod models;
pub mod parser;
pub mod subtitle;

pub use analyzer::MetadataAnalyzer;
pub use error::MetadataError;
pub use events::MetadataEvent;
pub use models::*;
pub use parser::RawFileEntry;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
