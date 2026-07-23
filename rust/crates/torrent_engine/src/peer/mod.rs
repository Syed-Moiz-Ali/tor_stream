//! Peer management — tracks connection statistics per torrent.
//!
//! This module wraps the peer stats exposed by `librqbit::TorrentStats`
//! and emits [`crate::events::EngineEvent::PeerConnected`] /
//! [`crate::events::EngineEvent::PeerDisconnected`] when the live peer set
//! changes between polling intervals.

use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use tokio::sync::Mutex;
use crate::models::{TorrentId, PeerStats};

/// Tracks the set of live peer addresses per torrent.
///
/// Comparing the previous set against the current set each poll cycle
/// allows us to detect individual connections and disconnections.
#[derive(Clone, Default)]
pub struct PeerManager {
    /// `torrent_id` → set of peer socket addresses currently live.
    live_peers: Arc<Mutex<HashMap<TorrentId, HashSet<String>>>>,
}

impl PeerManager {
    pub fn new() -> Self {
        Self::default()
    }

    /// Diff the current live peers against the stored set.
    ///
    /// Returns `(connected, disconnected)` where each is a `Vec<String>` of
    /// peer socket addresses that appeared / disappeared since the last call.
    pub async fn diff(
        &self,
        id: TorrentId,
        current_peers: HashSet<String>,
    ) -> (Vec<String>, Vec<String>) {
        let mut guard = self.live_peers.lock().await;
        let prev = guard.entry(id).or_insert_with(HashSet::new);

        let connected:    Vec<String> = current_peers.difference(prev).cloned().collect();
        let disconnected: Vec<String> = prev.difference(&current_peers).cloned().collect();

        *prev = current_peers;
        (connected, disconnected)
    }

    /// Remove all tracking data for a torrent.
    pub async fn remove(&self, id: TorrentId) {
        self.live_peers.lock().await.remove(&id);
    }

    /// Compute a [`PeerStats`] from raw counts (convenience helper).
    pub fn build_stats(
        queued: u32,
        connecting: u32,
        live: u32,
        seen: u32,
        dead: u32,
    ) -> PeerStats {
        PeerStats { queued, connecting, live, seen, dead }
    }
}
