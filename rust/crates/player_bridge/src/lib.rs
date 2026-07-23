//! `player_bridge` — Phase 5 Android Media3 Delivery & JNI Bridge.

pub mod datasource;
pub mod reader;
pub mod state;
pub mod statistics;
pub mod jni;

pub use datasource::{close_handle, get_handle, open_handle, ActiveStreamHandle};

pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
