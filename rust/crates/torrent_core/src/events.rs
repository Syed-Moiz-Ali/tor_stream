//! Async event bus for the TorStream engine.
//!
//! Events flow **Rust → Flutter** via `flutter_rust_bridge` `StreamSink`.
//! Internally, components publish to a `broadcast::channel`; the FFI bridge
//! subscribes and forwards events to Dart.
//!
//! ## Event flow
//! ```text
//! libtorrent alert
//!     → SessionManager::poll_loop()
//!     → EventBus::publish(TorrentEvent)
//!     → broadcast::channel (bounded 256)
//!     → ffi_bridge subscriber
//!     → FRB StreamSink
//!     → Dart Stream<TorrentEvent>
//!     → Riverpod StreamProvider
//!     → Widget rebuild
//! ```

use serde::{Deserialize, Serialize};
use tokio::sync::broadcast;

/// Capacity of the internal broadcast channel.
/// Old events are dropped when the channel is full (non-blocking).
const CHANNEL_CAPACITY: usize = 256;

// ── Event types ───────────────────────────────────────────────────────────────

/// All events emitted by the Rust engine.
///
/// This enum is the **only** way the engine communicates state changes
/// to Flutter. Dart code must never poll — only subscribe to events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TorrentEvent {
    // ── Torrent lifecycle ────────────────────────────────────────────────────
    /// A torrent was added successfully and metadata is resolved.
    Added {
        torrent_id: String,
        name:       String,
        total_size: i64,
    },
    /// Torrent download/upload state changed.
    StateChanged {
        torrent_id:  String,
        new_status:  TorrentStatus,
    },
    /// Periodic progress update (emitted every ~2 seconds while active).
    ProgressUpdate {
        torrent_id:     String,
        progress:       f32,  // 0.0 → 1.0
        download_speed: i64,  // bytes/s
        upload_speed:   i64,  // bytes/s
        eta_seconds:    Option<i64>,
        num_peers:      i32,
        num_seeds:      i32,
    },
    /// A piece was verified and written to disk.
    PieceFinished {
        torrent_id:  String,
        piece_index: i32,
    },
    /// A torrent was removed.
    Removed {
        torrent_id: String,
    },

    // ── Streaming lifecycle ───────────────────────────────────────────────────
    /// Stream server is ready; ExoPlayer can connect.
    StreamReady {
        torrent_id: String,
        file_index: i32,
        url:        String,
    },
    /// Playback stalled (insufficient buffered pieces).
    StreamStall {
        torrent_id: String,
        file_index: i32,
    },
    /// Stall resolved; playback can resume.
    StreamRecovered {
        torrent_id: String,
        file_index: i32,
    },
    /// Stream was stopped.
    StreamStopped {
        torrent_id: String,
        file_index: i32,
    },

    // ── Error events ──────────────────────────────────────────────────────────
    /// A recoverable or fatal error occurred.
    Error {
        torrent_id: Option<String>,
        message:    String,
        fatal:      bool,
    },
}

/// Torrent status — mirrors libtorrent's `torrent_status::state_t`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum TorrentStatus {
    /// Queued, waiting to be added to session.
    Queued,
    /// Checking existing files on disk.
    Checking,
    /// Downloading metadata (magnet link).
    FetchingMetadata,
    /// Actively downloading.
    Downloading,
    /// Fully downloaded; uploading to peers.
    Seeding,
    /// Paused by the user.
    Paused,
    /// A non-recoverable error occurred.
    Error,
}

// ── EventBus ──────────────────────────────────────────────────────────────────

/// Thread-safe event bus backed by a `tokio::sync::broadcast` channel.
///
/// Any number of subscribers can receive events. If a subscriber is slow,
/// it will miss events (broadcast semantics) — the UI only needs the latest
/// state anyway.
#[derive(Clone)]
pub struct EventBus {
    sender: broadcast::Sender<TorrentEvent>,
}

impl EventBus {
    /// Create a new [`EventBus`] with [`CHANNEL_CAPACITY`] slots.
    pub fn new() -> Self {
        let (sender, _) = broadcast::channel(CHANNEL_CAPACITY);
        Self { sender }
    }

    /// Publish an event to all current subscribers.
    ///
    /// Returns the number of active receivers that received the event.
    /// A return value of 0 means no one is listening (fine — events are
    /// fire-and-forget).
    pub fn publish(&self, event: TorrentEvent) -> usize {
        match self.sender.send(event) {
            Ok(n)  => n,
            Err(_) => 0, // No active receivers — not an error
        }
    }

    /// Subscribe to the event stream.
    ///
    /// The returned [`broadcast::Receiver`] receives all events published
    /// *after* this call. Callers are responsible for handling
    /// [`broadcast::error::RecvError::Lagged`].
    pub fn subscribe(&self) -> broadcast::Receiver<TorrentEvent> {
        self.sender.subscribe()
    }
}

impl Default for EventBus {
    fn default() -> Self {
        Self::new()
    }
}
