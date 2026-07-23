//! `torrent_engine` — Phase 2 production torrent session manager.
//!
//! ## Architecture
//!
//! ```text
//! ffi_bridge  (Dart-facing FFI layer)
//!     ↓ calls
//! torrent_engine::bridge  (public API surface, no FFI annotations)
//!     ↓ delegates to
//! TorrentEngine  (singleton; owns all subsystems)
//!     ├── TorrentSession   (wraps librqbit::Session)
//!     ├── TorrentManager   (coordinates operations + events)
//!     ├── ResumeManager    → ResumeStore (SQLite)
//!     ├── DhtManager
//!     └── EventBus         (tokio::broadcast channel)
//! ```
//!
//! ## Usage (from ffi_bridge)
//!
//! ```rust,ignore
//! use torrent_engine::bridge as engine;
//!
//! // Startup
//! engine::initialize_engine(config).await?;
//!
//! // Add a torrent
//! let id = engine::add_magnet("magnet:?xt=...".into()).await?;
//!
//! // Subscribe to events
//! let mut rx = engine::subscribe_events();
//! while let Ok(event) = rx.recv().await { ... }
//!
//! // Shutdown
//! engine::shutdown_engine().await?;
//! ```

#![warn(missing_docs)]

// ── Modules ───────────────────────────────────────────────────────────────────
pub mod bridge;
pub mod config;
pub mod dht;
pub mod engine;
pub mod error;
pub mod events;
pub mod models;
pub mod peer;
pub mod resume;
pub mod session;
pub mod torrent;
pub mod tracker;

// ── Re-exports for convenience ────────────────────────────────────────────────

/// The complete engine configuration.
pub use config::EngineConfig;

/// All error types.
pub use error::EngineError;

/// All event types + the EventBus.
pub use events::{EngineEvent, EventBus};

/// Core data models.
pub use models::{PeerStats, TorrentFileInfo, TorrentId, TorrentInfo, TorrentStatus};

/// Version constant consumed by ffi_bridge.
pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
