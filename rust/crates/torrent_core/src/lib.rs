//! # TorStream Core Engine
//!
//! This crate contains **all** business logic for the TorStream application.
//! The Flutter UI layer must never contain torrent logic; everything lives here.
//!
//! ## Architecture
//!
//! ```text
//! Flutter UI
//!     │
//! flutter_rust_bridge  (ffi_bridge crate)
//!     │
//! TorStream Core  ← YOU ARE HERE
//!     ├── config    — App + session configuration
//!     ├── error     — Unified error types
//!     ├── events    — Async event bus
//!     └── logger    — tracing subscriber setup
//! ```
//!
//! ## Phase Notes
//!
//! Phase 1 — Scaffold only. Modules are defined but contain no torrent logic.
//! Phase 2 — Session management + libtorrent integration.
//! Phase 3 — Streaming server + piece scheduler.

pub mod config;
pub mod error;
pub mod events;
pub mod logger;

// ── Phase 2+ modules (uncomment as each phase is implemented) ─────────────────
// pub mod session;       // Phase 2: libtorrent session lifecycle
// pub mod metadata;      // Phase 2: magnet resolution + .torrent parsing
// pub mod scheduler;     // Phase 3: piece priority + sequential window
// pub mod stream_server; // Phase 3: local HTTP streaming server
// pub mod storage;       // Phase 2: SQLite + file I/O

/// Engine version, derived from Cargo.toml at compile time.
pub const ENGINE_VERSION: &str = env!("CARGO_PKG_VERSION");
