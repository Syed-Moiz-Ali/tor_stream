//! Torrent management operations.
//!
//! [`TorrentManager`] provides higher-level operations on individual torrents,
//! building on top of [`crate::session::TorrentSession`]. It validates inputs,
//! records metadata in SQLite via [`crate::resume::ResumeStore`], and publishes
//! lifecycle events via [`crate::events::EventBus`].

pub mod state;

use std::sync::Arc;
use tracing::{info, instrument};

use crate::error::{EngineError, Result};
use crate::events::{EngineEvent, EventBus};
use crate::models::{TorrentId, TorrentInfo, TorrentStatus};
use crate::resume::ResumeManager;
use crate::session::TorrentSession;
use self::state::{StateTransition, TorrentStateTracker};

/// Coordinates torrent operations across the session, resume store, and event bus.
#[derive(Clone)]
pub struct TorrentManager {
    session:   TorrentSession,
    state:     TorrentStateTracker,
    resume:    Arc<ResumeManager>,
    event_bus: EventBus,
}

impl TorrentManager {
    pub fn new(
        session:   TorrentSession,
        resume:    Arc<ResumeManager>,
        event_bus: EventBus,
    ) -> Self {
        Self {
            session,
            state: TorrentStateTracker::new(),
            resume,
            event_bus,
        }
    }

    // ── Public operations ─────────────────────────────────────────────────────

    /// Add a torrent from a magnet URI.
    ///
    /// Validates the URI, adds it to the session, persists the record to SQLite,
    /// and emits [`EngineEvent::TorrentAdded`].
    #[instrument(skip(self))]
    pub async fn add_magnet(&self, magnet_uri: String) -> Result<TorrentId> {
        let (id, handle) = self.session.add_magnet(magnet_uri).await?;

        let save_path = self.session.download_dir().to_string_lossy().to_string();
        let now_ms    = chrono_now_ms();
        let info_hash = handle.info_hash();
        let name      = handle.name();
        let total     = handle.total_bytes();

        // Persist to SQLite.
        self.resume
            .store()
            .upsert_torrent(id, &info_hash, name.as_deref(), &save_path, now_ms)
            .await?;

        // Immediately add to in-memory state tracker so that getAllTorrents()
        // returns it right away, without waiting for the 2-second poll loop.
        let info = handle.torrent_info(&save_path, now_ms);
        self.state.update(info).await;

        self.event_bus.publish(EngineEvent::TorrentAdded {
            id,
            name,
            total_bytes: total,
        });

        info!(id, info_hash, "Magnet added");
        Ok(id)
    }

    /// Add a torrent from raw `.torrent` file bytes.
    #[instrument(skip(self, data), fields(bytes = data.len()))]
    pub async fn add_torrent_file(&self, data: Vec<u8>) -> Result<TorrentId> {
        let (id, handle) = self.session.add_torrent_file(data).await?;

        let save_path = self.session.download_dir().to_string_lossy().to_string();
        let now_ms    = chrono_now_ms();
        let info_hash = handle.info_hash();
        let name      = handle.name();
        let total     = handle.total_bytes();

        self.resume
            .store()
            .upsert_torrent(id, &info_hash, name.as_deref(), &save_path, now_ms)
            .await?;

        // Immediately add to in-memory state tracker.
        let info = handle.torrent_info(&save_path, now_ms);
        self.state.update(info).await;

        self.event_bus.publish(EngineEvent::TorrentAdded {
            id,
            name,
            total_bytes: total,
        });

        info!(id, info_hash, "Torrent file added");
        Ok(id)
    }

    /// Pause a torrent and update its SQLite status.
    #[instrument(skip(self), fields(id))]
    pub async fn pause(&self, id: TorrentId) -> Result<()> {
        self.session.pause(id).await?;
        self.resume.store().set_status(id, TorrentStatus::Paused).await?;
        self.event_bus.publish(EngineEvent::DownloadPaused { id });
        info!(id, "Torrent paused");
        Ok(())
    }

    /// Resume a paused torrent and update its SQLite status.
    #[instrument(skip(self), fields(id))]
    pub async fn resume_torrent(&self, id: TorrentId) -> Result<()> {
        self.session.resume(id).await?;
        self.resume.store().set_status(id, TorrentStatus::Downloading).await?;
        self.event_bus.publish(EngineEvent::DownloadStarted { id });
        info!(id, "Torrent resumed");
        Ok(())
    }

    /// Remove a torrent from the session and delete its SQLite record.
    #[instrument(skip(self), fields(id, delete_files))]
    pub async fn remove(&self, id: TorrentId, delete_files: bool) -> Result<()> {
        self.session.remove(id, delete_files).await?;
        self.state.remove(id).await;
        self.resume.store().delete_torrent(id).await?;
        self.event_bus.publish(EngineEvent::TorrentRemoved { id });
        info!(id, delete_files, "Torrent removed");
        Ok(())
    }

    /// Get the current status snapshot for a single torrent.
    pub async fn get_status(&self, id: TorrentId) -> Result<TorrentInfo> {
        self.state.get(id).await.ok_or(EngineError::TorrentNotFound { id })
    }

    /// Get the status snapshots for all managed torrents.
    pub async fn get_all_statuses(&self) -> Vec<TorrentInfo> {
        self.state.get_all().await
    }

    // ── Polling (called by engine background task) ─────────────────────────

    /// Refresh stats for all torrents and emit appropriate events.
    ///
    /// Called every 2 seconds by the engine polling task.
    pub async fn poll_all(&self) {
        let ids = self.session.all_ids();
        for id in ids {
            if let Err(e) = self.poll_one(id).await {
                tracing::warn!(id, error = %e, "Failed to poll torrent stats");
            }
        }
    }

    async fn poll_one(&self, id: TorrentId) -> Result<()> {
        let handle = self.session.get(id)?;

        // Get the persisted save_path and added_at from the state or SQLite.
        let (save_path, added_at_ms) = self
            .state
            .get(id)
            .await
            .map(|i| (i.save_path, i.added_at_ms))
            .unwrap_or_else(|| {
                (
                    self.session.download_dir().to_string_lossy().to_string(),
                    0,
                )
            });

        let info       = handle.torrent_info(&save_path, added_at_ms);
        let transition = self.state.update(info.clone()).await;

        // Emit lifecycle events for state changes.
        match transition {
            StateTransition::StatusChanged { to: TorrentStatus::Seeding, .. } => {
                self.event_bus.publish(EngineEvent::DownloadFinished { id });
            }
            StateTransition::StatusChanged { to: TorrentStatus::Downloading, .. } => {
                self.event_bus.publish(EngineEvent::DownloadStarted { id });
            }
            StateTransition::StatusChanged { to: TorrentStatus::FetchingMetadata, .. } |
            StateTransition::Added => {}
            _ => {}
        }

        // Emit peer stats.
        let peer_stats = handle.peer_stats();
        self.event_bus.publish(EngineEvent::PeerUpdate { id, stats: peer_stats });

        // Always emit a progress update.
        self.event_bus.publish(EngineEvent::ProgressUpdate { id, info });

        Ok(())
    }
}

/// Returns the current Unix epoch time in milliseconds.
fn chrono_now_ms() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}
