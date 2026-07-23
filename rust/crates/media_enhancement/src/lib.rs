//! `media_enhancement` — Phase 9 Media Enhancement Engine.

pub mod audio_engine;
pub mod bridge;
pub mod chapter_engine;
pub mod error;
pub mod events;
pub mod media_info;
pub mod models;
pub mod playback_engine;
pub mod subtitle_engine;
pub mod thumbnail_engine;

pub use error::MediaEnhancementError;
pub use models::*;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
