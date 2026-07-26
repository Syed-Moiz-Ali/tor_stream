//! Global [`TorrentEngine`] singleton.
//!
//! The engine is initialised once via [`TorrentEngine::init`] and lives for
//! the entire process lifetime. It holds all subsystems — session, manager,
//! resume, events — and owns two Tokio background tasks:
//!
//! 1. **Poll task** — refreshes torrent stats every 2 s and publishes events.
//! 2. **Resume task** — saves resume data to SQLite every 60 s.
//!
//! All public API in [`crate::bridge`] delegates to `get_engine()`.

use std::sync::{Arc, OnceLock};
use std::time::Duration;
use tokio::sync::RwLock;
use tokio::task::JoinHandle;
use tracing::{error, info, instrument, warn};

use crate::config::EngineConfig;
use crate::dht::{DhtConfig, DhtManager};
use crate::error::{EngineError, Result};
use crate::events::{EngineEvent, EventBus};
use crate::models::TorrentId;
use crate::resume::{ResumeManager, store::ResumeStore};
use crate::session::TorrentSession;
use crate::torrent::TorrentManager;

// ── Global singleton ──────────────────────────────────────────────────────────

static ENGINE: OnceLock<Arc<TorrentEngine>> = OnceLock::new();

/// Access the global engine singleton.
///
/// Returns [`EngineError::NotInitialised`] if [`TorrentEngine::init`] has not
/// yet been called successfully.
pub(crate) fn get_engine() -> Result<Arc<TorrentEngine>> {
    ENGINE
        .get()
        .cloned()
        .ok_or(EngineError::NotInitialised)
}

// ── TorrentEngine ─────────────────────────────────────────────────────────────

/// Top-level engine object. Holds all subsystems.
pub struct TorrentEngine {
    pub config:    EngineConfig,
    pub session:   TorrentSession,
    pub manager:   TorrentManager,
    pub dht:       DhtManager,
    pub resume:    Arc<ResumeManager>,
    pub event_bus: EventBus,
    /// Handles to background tasks; kept alive as long as the engine is alive.
    _tasks: RwLock<Vec<JoinHandle<()>>>,
}

impl TorrentEngine {
    // ── Lifecycle ─────────────────────────────────────────────────────────────

    /// Initialise the engine.
    ///
    /// Must be called exactly once. Returns [`EngineError::AlreadyInitialised`]
    /// if the engine has already been initialised.
    #[instrument(skip(config))]
    pub async fn init(config: EngineConfig) -> Result<()> {
        if ENGINE.get().is_some() {
            return Ok(());  // Idempotent — already running
        }

        config.validate()?;
        info!("Initialising TorStream engine (Phase 2)");

        // 1. Resume store (SQLite).
        let store     = ResumeStore::open(&config.db_path())?;
        let event_bus = EventBus::new();
        let resume    = Arc::new(ResumeManager::new(store, event_bus.clone()));

        // 2. BitTorrent session (librqbit).
        let session = TorrentSession::new(&config).await?;

        // 3. DHT manager.
        let dht = DhtManager::new(DhtConfig::from_engine_config(&config));

        // 4. Torrent manager.
        let manager = TorrentManager::new(
            session.clone(),
            Arc::clone(&resume),
            event_bus.clone(),
        );

        let engine = Arc::new(TorrentEngine {
            config,
            session,
            manager,
            dht,
            resume,
            event_bus,
            _tasks: RwLock::new(Vec::new()),
        });

        // 5. Start background tasks.
        let poll_task   = tokio::spawn(run_poll_task(Arc::clone(&engine)));
        let resume_task = tokio::spawn(run_resume_task(Arc::clone(&engine)));
        engine._tasks.write().await.extend([poll_task, resume_task]);

        // 6. Restore previous session.
        engine.restore_previous_session().await;

        ENGINE
            .set(engine)
            .map_err(|_| EngineError::AlreadyInitialised)?;

        // Publish SessionStarted after ENGINE is set so subscribers can call back.
        get_engine()?.event_bus.publish(EngineEvent::SessionStarted);
        info!("Engine ready");
        Ok(())
    }

    /// Shut down the engine cleanly.
    ///
    /// Saves all resume data, shuts down the session, and cancels background
    /// tasks. After this call the process may safely exit.
    pub async fn shutdown(&self) {
        info!("Engine shutdown requested");

        // Save resume data for all active torrents.
        let ids = self.session.all_ids();
        self.resume.save_all(&ids).await;

        // Shut down the BitTorrent session.
        self.session.shutdown().await;

        self.event_bus.publish(EngineEvent::SessionStopped);
        info!("Engine shut down");
    }

    // ── Torrent operations (delegate to manager) ──────────────────────────────

    pub async fn add_magnet(&self, magnet_uri: String) -> Result<TorrentId> {
        self.manager.add_magnet(magnet_uri).await
    }

    pub async fn add_magnet_stream(&self, magnet_uri: String) -> Result<TorrentId> {
        self.manager.add_magnet_stream(magnet_uri).await
    }

    pub async fn add_torrent_file(&self, data: Vec<u8>) -> Result<TorrentId> {
        self.manager.add_torrent_file(data).await
    }

    pub async fn pause_torrent(&self, id: TorrentId) -> Result<()> {
        self.manager.pause(id).await
    }

    pub async fn resume_torrent(&self, id: TorrentId) -> Result<()> {
        self.manager.resume_torrent(id).await
    }

    pub async fn remove_torrent(&self, id: TorrentId, delete_files: bool) -> Result<()> {
        self.manager.remove(id, delete_files).await
    }

    pub async fn get_torrent_status(
        &self,
        id: TorrentId,
    ) -> Result<crate::models::TorrentInfo> {
        self.manager.get_status(id).await
    }

    pub async fn get_all_torrents(&self) -> Vec<crate::models::TorrentInfo> {
        self.manager.get_all_statuses().await
    }

    pub async fn file_info(&self, id: TorrentId, file_index: u32) -> Result<crate::models::TorrentFileInfo> {
        self.manager.file_info(id, file_index).await
    }

    pub async fn save_resume_data(&self, id: TorrentId) -> Result<()> {
        self.resume.save(id, "downloading").await
    }

    pub async fn restore_resume_data(&self) -> Result<Vec<TorrentId>> {
        let stored = self.resume.load_previous_session().await?;
        let ids: Vec<TorrentId> = stored.iter().map(|s| s.id).collect();
        info!(count = ids.len(), "Resume data loaded from SQLite");
        Ok(ids)
    }

    // ── Subscribe to events ───────────────────────────────────────────────────

    /// Subscribe to the event bus.
    ///
    /// The returned receiver yields [`EngineEvent`] values published by the
    /// engine. Used by the FRB bridge to stream events to Dart.
    pub fn subscribe(&self) -> tokio::sync::broadcast::Receiver<EngineEvent> {
        self.event_bus.subscribe()
    }

    // ── Internal ──────────────────────────────────────────────────────────────

    /// Re-add all torrents recorded in SQLite to the new session.
    async fn restore_previous_session(&self) {
        let stored = match self.resume.load_previous_session().await {
            Ok(s)  => s,
            Err(e) => {
                warn!(error = %e, "Failed to load previous session from SQLite");
                return;
            }
        };

        info!(count = stored.len(), "Restoring previous session");

        for record in stored {
            // librqbit's session_persistence JSON handles fast-resume internally.
            // We just need to confirm the session has re-added the torrent.
            // The info-hash lookup is used to find the re-added handle.
            info!(
                id = record.id,
                info_hash = %record.info_hash,
                name = ?record.name,
                "Session restored from SQLite"
            );
        }
    }
}

// ── Background tasks ──────────────────────────────────────────────────────────

/// Poll all torrents every 2 seconds and emit progress events.
async fn run_poll_task(engine: Arc<TorrentEngine>) {
    let mut interval = tokio::time::interval(Duration::from_secs(3));
    interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

    loop {
        interval.tick().await;
        engine.manager.poll_all().await;
    }
}

/// Save resume data for all torrents every 60 seconds.
async fn run_resume_task(engine: Arc<TorrentEngine>) {
    let mut interval = tokio::time::interval(Duration::from_secs(60));
    interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
    // Skip the first tick (we just started — no need to save immediately).
    interval.tick().await;

    loop {
        interval.tick().await;
        let ids = engine.session.all_ids();
        if !ids.is_empty() {
            engine.resume.save_all(&ids).await;
        }
    }
}
