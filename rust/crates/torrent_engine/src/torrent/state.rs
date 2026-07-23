//! Torrent state tracking.
//!
//! Tracks the last-known [`TorrentInfo`] for each managed torrent.
//! The polling loop (in `engine.rs`) calls [`TorrentStateTracker::update`]
//! every 2 seconds and publishes a [`crate::events::EngineEvent::ProgressUpdate`]
//! when the state changes.

use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use crate::models::{TorrentId, TorrentInfo, TorrentStatus};

/// Holds the last-known [`TorrentInfo`] per torrent.
///
/// Used to detect state transitions (e.g., `Downloading` → `Seeding`)
/// and emit the appropriate lifecycle events.
#[derive(Clone)]
pub struct TorrentStateTracker {
    states: Arc<RwLock<HashMap<TorrentId, TorrentInfo>>>,
}

impl TorrentStateTracker {
    pub fn new() -> Self {
        Self {
            states: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Insert or update the tracked state for `id`.
    ///
    /// Returns `StateTransition` describing what changed.
    pub async fn update(&self, info: TorrentInfo) -> StateTransition {
        let id = info.id;
        let mut guard = self.states.write().await;
        let transition = match guard.get(&id) {
            None => StateTransition::Added,
            Some(prev) => {
                if prev.status != info.status {
                    StateTransition::StatusChanged {
                        from: prev.status,
                        to:   info.status,
                    }
                } else {
                    StateTransition::Updated
                }
            }
        };
        guard.insert(id, info);
        transition
    }

    /// Remove tracking for a torrent (called on removal).
    pub async fn remove(&self, id: TorrentId) -> Option<TorrentInfo> {
        self.states.write().await.remove(&id)
    }

    /// Returns a snapshot of the last-known info for a torrent.
    pub async fn get(&self, id: TorrentId) -> Option<TorrentInfo> {
        self.states.read().await.get(&id).cloned()
    }

    /// Returns snapshots of all tracked torrents.
    pub async fn get_all(&self) -> Vec<TorrentInfo> {
        self.states.read().await.values().cloned().collect()
    }

    /// Returns all tracked torrent IDs.
    pub async fn all_ids(&self) -> Vec<TorrentId> {
        self.states.read().await.keys().copied().collect()
    }
}

impl Default for TorrentStateTracker {
    fn default() -> Self {
        Self::new()
    }
}

/// Describes what changed when [`TorrentStateTracker::update`] was called.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StateTransition {
    /// This torrent is being tracked for the first time.
    Added,
    /// The status field changed — emit a lifecycle event.
    StatusChanged { from: TorrentStatus, to: TorrentStatus },
    /// Values changed but the status is the same (progress, speed, etc.).
    Updated,
}
