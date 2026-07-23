//! Session handle — a thin `Arc` wrapper around librqbit's `ManagedTorrentHandle`.
//!
//! Provides clean methods with our own error types, hiding the librqbit API
//! from the rest of the engine. If librqbit's API changes, only this file
//! and `session/mod.rs` need updating.

use std::sync::Arc;
use librqbit::ManagedTorrent;
use crate::models::{TorrentId, TorrentInfo, TorrentStatus, PeerStats};

/// Wraps a `librqbit::ManagedTorrentHandle` with engine-typed methods.
#[derive(Clone)]
pub struct TorrentHandle {
    pub(super) id:     TorrentId,
    pub(super) inner:  Arc<ManagedTorrent>,
}

impl TorrentHandle {
    pub(super) fn new(id: TorrentId, inner: Arc<ManagedTorrent>) -> Self {
        Self { id, inner }
    }

    /// Unique ID of this torrent within the current session.
    pub fn id(&self) -> TorrentId {
        self.id
    }

    /// 40-hex SHA-1 info-hash string.
    pub fn info_hash(&self) -> String {
        hex::encode(self.inner.info_hash().0)
    }

    /// Display name from torrent metadata, or `None` while fetching.
    pub fn name(&self) -> Option<String> {
        self.inner.name()
    }

    /// Total content size in bytes, or 0 while metadata is still downloading.
    pub fn total_bytes(&self) -> u64 {
        self.inner.stats().total_bytes
    }

    /// Build a [`TorrentInfo`] snapshot from the current stats.
    pub fn torrent_info(&self, save_path: &str, added_at_ms: i64) -> TorrentInfo {
        let stats = self.inner.stats();
        let name  = self.inner.name();

        let status = match &stats.state {
            librqbit::TorrentStatsState::Initializing => {
                if name.is_none() {
                    TorrentStatus::FetchingMetadata
                } else {
                    TorrentStatus::Checking
                }
            }
            librqbit::TorrentStatsState::Live         => TorrentStatus::Downloading,
            librqbit::TorrentStatsState::Paused       => TorrentStatus::Paused,
            librqbit::TorrentStatsState::Error         => TorrentStatus::Error,
        };

        // Compute progress: avoid division by zero when total is unknown.
        let progress = if stats.total_bytes > 0 {
            stats.progress_bytes as f64 / stats.total_bytes as f64
        } else {
            0.0
        };

        // Determine if we are seeding (progress == 1.0 and live).
        let status = if progress >= 1.0 && status == TorrentStatus::Downloading {
            TorrentStatus::Seeding
        } else {
            status
        };

        let (download_rate, upload_rate) = stats
            .live
            .as_ref()
            .map(|l| {
                (
                    (l.download_speed.mbps * 1_000_000.0 / 8.0) as u64,
                    (l.upload_speed.mbps   * 1_000_000.0 / 8.0) as u64,
                )
            })
            .unwrap_or((0, 0));

        let num_peers = stats
            .live
            .as_ref()
            .map(|l| l.snapshot.peer_stats.live)
            .unwrap_or(0) as u32;

        TorrentInfo {
            id:               self.id,
            info_hash:        self.info_hash(),
            name,
            status,
            progress:         progress.clamp(0.0, 1.0),
            download_rate,
            upload_rate,
            total_bytes:      stats.total_bytes,
            downloaded_bytes: stats.progress_bytes,
            num_peers,
            save_path:        save_path.to_owned(),
            added_at_ms,
        }
    }

    /// Build a [`PeerStats`] snapshot.
    pub fn peer_stats(&self) -> PeerStats {
        let stats = self.inner.stats();
        let ps = stats.live.as_ref().map(|l| &l.snapshot.peer_stats);
        PeerStats {
            queued:     ps.map_or(0, |p| p.queued)     as u32,
            connecting: ps.map_or(0, |p| p.connecting) as u32,
            live:       ps.map_or(0, |p| p.live)       as u32,
            seen:       ps.map_or(0, |p| p.seen)       as u32,
            dead:       ps.map_or(0, |p| p.dead)       as u32,
        }
    }


}
