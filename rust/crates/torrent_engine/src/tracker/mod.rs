//! Tracker management — records the last announce result per tracker URL.
//!
//! librqbit communicates with trackers internally. This module aggregates
//! tracker information from torrent stats and emits
//! [`crate::events::EngineEvent::TrackerUpdated`] on changes.

use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use crate::models::{TorrentId, TrackerInfo};

/// Stores the most-recent announce result from each tracker.
#[derive(Clone, Default)]
pub struct TrackerManager {
    /// `torrent_id` → list of tracker infos seen for that torrent.
    trackers: Arc<RwLock<HashMap<TorrentId, Vec<TrackerInfo>>>>,
}

impl TrackerManager {
    pub fn new() -> Self {
        Self::default()
    }

    /// Update the stored tracker list for a torrent and return the entries
    /// whose `peers_returned` or `last_error` changed.
    pub async fn update(
        &self,
        id: TorrentId,
        current: Vec<TrackerInfo>,
    ) -> Vec<TrackerInfo> {
        let mut guard = self.trackers.write().await;
        let prev = guard.entry(id).or_insert_with(Vec::new);

        // Identify changed entries by URL.
        let changed: Vec<TrackerInfo> = current
            .iter()
            .filter(|c| {
                !prev.iter().any(|p| {
                    p.url == c.url
                        && p.peers_returned == c.peers_returned
                        && p.last_error == c.last_error
                })
            })
            .cloned()
            .collect();

        *prev = current;
        changed
    }

    /// Remove tracker data for a torrent.
    pub async fn remove(&self, id: TorrentId) {
        self.trackers.write().await.remove(&id);
    }

    /// Get the last-known tracker list for a torrent.
    pub async fn get(&self, id: TorrentId) -> Vec<TrackerInfo> {
        self.trackers
            .read()
            .await
            .get(&id)
            .cloned()
            .unwrap_or_default()
    }
}
