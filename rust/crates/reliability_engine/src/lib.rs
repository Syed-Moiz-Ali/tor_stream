//! `reliability_engine` — Phase 7 Reliability, Persistence & Recovery Engine.

pub mod backup;
pub mod bridge;
pub mod error;
pub mod events;
pub mod health;
pub mod models;
pub mod network;
pub mod persistence;
pub mod recovery;
pub mod resume;
pub mod verification;

pub use error::ReliabilityError;
pub use models::*;

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
