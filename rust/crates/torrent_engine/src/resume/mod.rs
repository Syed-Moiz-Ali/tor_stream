//! Resume data orchestration.
//!
//! [`ResumeManager`] coordinates periodic saves of resume data to SQLite
//! and orchestrates session restore on startup. It wraps [`ResumeStore`] and
//! adds the scheduling and event-publishing logic.

pub mod store;

use std::sync::Arc;
use tracing::{info, instrument, warn};

use crate::error::{EngineError, Result};
use crate::events::{EngineEvent, EventBus};
use crate::models::TorrentId;
use self::store::{ResumeStore, StoredTorrent};

/// Orchestrates resume data persistence for all managed torrents.
#[derive(Clone)]
pub struct ResumeManager {
    store:     Arc<ResumeStore>,
    event_bus: EventBus,
}

impl ResumeManager {
    /// Create a new [`ResumeManager`] backed by the given store.
    pub fn new(store: ResumeStore, event_bus: EventBus) -> Self {
        Self {
            store:     Arc::new(store),
            event_bus,
        }
    }

    /// Returns a reference to the underlying [`ResumeStore`].
    pub fn store(&self) -> &ResumeStore {
        &self.store
    }

    // ── Save ──────────────────────────────────────────────────────────────────

    /// Explicitly save resume data for a single torrent.
    ///
    /// In Phase 2, resume data consists of the torrent's current status stored
    /// in SQLite. The librqbit session handles the fast-resume binary data
    /// internally via its `session_persistence` JSON file.
    #[instrument(skip(self), fields(id))]
    pub async fn save(&self, id: TorrentId, status_label: &str) -> Result<()> {
        // Persist a lightweight resume blob: the status label as JSON bytes.
        let data = serde_json::to_vec(status_label)
            .map_err(EngineError::Serialisation)?;

        self.store.save_resume_data(id, data).await?;
        self.event_bus.publish(EngineEvent::ResumeSaved { id });

        info!(id, "Resume data saved");
        Ok(())
    }

    /// Save resume data for all provided torrent IDs.
    ///
    /// Called periodically (every 60 s) and on engine shutdown.
    pub async fn save_all(&self, ids: &[TorrentId]) {
        for &id in ids {
            if let Err(e) = self.save(id, "downloading").await {
                warn!(id, error = %e, "Failed to save resume data");
            }
        }
    }

    // ── Restore ───────────────────────────────────────────────────────────────

    /// Load all previously managed torrents from SQLite.
    ///
    /// Returns the stored torrent records so the caller (engine) can re-add
    /// each one to the new session via the appropriate magnet/file path.
    pub async fn load_previous_session(&self) -> Result<Vec<StoredTorrent>> {
        let stored = self.store.load_all_torrents().await?;
        info!(
            count = stored.len(),
            "Loaded previous session from SQLite"
        );
        Ok(stored)
    }

    /// Load the raw resume data blob for a single torrent, if present.
    pub async fn load_resume_data(&self, id: TorrentId) -> Result<Option<Vec<u8>>> {
        self.store.load_resume_data(id).await
    }
}
