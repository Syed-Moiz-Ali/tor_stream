//! Strongly-typed event system for the torrent engine.
//!
//! All state changes are communicated via [`EngineEvent`] published to an
//! [`EventBus`]. The FFI bridge subscribes and forwards events to Dart via
//! a `flutter_rust_bridge` `StreamSink`.
//!
//! ## Flow
//! ```text
//! Engine internal state change
//!     → EventBus::publish(EngineEvent)
//!     → tokio::sync::broadcast::channel (capacity 512)
//!     → ffi_bridge subscriber task
//!     → StreamSink<TorrentEvent> (Dart)
//! ```

use tokio::sync::broadcast;
use serde::{Deserialize, Serialize};
use crate::models::{TorrentId, TorrentInfo, PeerStats, TrackerInfo};

/// Capacity of the broadcast channel.
/// If the channel is full, the oldest event is dropped (non-blocking).
const CHANNEL_CAPACITY: usize = 512;

// ── EngineEvent ────────────────────────────────────────────────────────────────

/// Every event the engine can emit.
///
/// Flutter only observes these events — it never polls. The engine is
/// the single source of truth; Flutter reflects it.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EngineEvent {
    // ── Session lifecycle ──────────────────────────────────────────────────
    /// Engine initialised successfully; session is running.
    SessionStarted,
    /// Engine has been shut down cleanly.
    SessionStopped,

    // ── Torrent lifecycle ──────────────────────────────────────────────────
    /// Torrent metadata received and torrent is added to the session.
    TorrentAdded { id: TorrentId, name: Option<String>, total_bytes: u64 },
    /// Metadata fetching complete (magnet → full info).
    MetadataReceived { id: TorrentId, name: String, total_bytes: u64 },
    /// Torrent was removed from the session.
    TorrentRemoved { id: TorrentId },

    // ── Download lifecycle ─────────────────────────────────────────────────
    /// Download has started (first piece being requested).
    DownloadStarted { id: TorrentId },
    /// Download paused by the user.
    DownloadPaused { id: TorrentId },
    /// All pieces downloaded and verified.
    DownloadFinished { id: TorrentId },

    // ── Periodic updates ───────────────────────────────────────────────────
    /// Emitted every 2 seconds for each active torrent.
    ProgressUpdate {
        id:             TorrentId,
        info:           TorrentInfo,
    },
    /// Peer connection counts changed.
    PeerUpdate {
        id:    TorrentId,
        stats: PeerStats,
    },
    /// Tracker responded to an announce.
    TrackerUpdated {
        id:      TorrentId,
        tracker: TrackerInfo,
    },

    // ── Peer events ────────────────────────────────────────────────────────
    /// A peer handshake succeeded.
    PeerConnected { id: TorrentId, peer_addr: String },
    /// A peer connection was closed.
    PeerDisconnected { id: TorrentId, peer_addr: String, reason: String },

    // ── Resume data ────────────────────────────────────────────────────────
    /// Resume data was saved to SQLite.
    ResumeSaved { id: TorrentId },

    // ── Error ──────────────────────────────────────────────────────────────
    /// A non-fatal error occurred; the engine remains running.
    Error {
        id:      Option<TorrentId>,
        message: String,
        fatal:   bool,
    },
}

// ── EventBus ──────────────────────────────────────────────────────────────────

/// Thread-safe, multi-subscriber event bus.
///
/// Backed by a `tokio::sync::broadcast` channel. Cloning an `EventBus`
/// shares the same underlying channel — all subscribers see all events.
#[derive(Clone)]
pub struct EventBus {
    sender: broadcast::Sender<EngineEvent>,
}

impl EventBus {
    /// Create a new [`EventBus`].
    pub fn new() -> Self {
        let (sender, _) = broadcast::channel(CHANNEL_CAPACITY);
        Self { sender }
    }

    /// Publish an event to all active subscribers.
    ///
    /// Returns the number of receivers that received the event.
    /// 0 receivers is not an error — events are fire-and-forget.
    pub fn publish(&self, event: EngineEvent) -> usize {
        match self.sender.send(event) {
            Ok(n)  => n,
            Err(_) => 0,
        }
    }

    /// Subscribe to the event stream.
    ///
    /// The returned receiver will receive events published *after* this call.
    /// Handle [`broadcast::error::RecvError::Lagged`] by catching up or resetting.
    pub fn subscribe(&self) -> broadcast::Receiver<EngineEvent> {
        self.sender.subscribe()
    }

    /// Returns the current number of active receivers.
    pub fn receiver_count(&self) -> usize {
        self.sender.receiver_count()
    }
}

impl Default for EventBus {
    fn default() -> Self {
        Self::new()
    }
}
