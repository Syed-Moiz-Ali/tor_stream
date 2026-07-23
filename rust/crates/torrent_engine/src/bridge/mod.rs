//! Public bridge API for the torrent engine.
//!
//! Every function here is a clean async function that delegates to the engine
//! singleton (`engine.rs`). Functions in this module are called from
//! `ffi_bridge/src/api.rs` which wraps them with `#[frb]` annotations.
//!
//! ## Design contract
//! - No librqbit types cross this boundary.
//! - Error types are converted to `anyhow::Error` for FRB compatibility.
//! - All functions are `async` (FRB v2 supports async natively).

use anyhow::Context;
use crate::config::EngineConfig;
use crate::engine::{TorrentEngine, get_engine};
use crate::events::EngineEvent;
use crate::models::{TorrentId, TorrentInfo};

// ── Engine lifecycle ───────────────────────────────────────────────────────────

/// Initialise the TorStream torrent engine.
///
/// Must be called once before any other engine function. Subsequent calls
/// return an error immediately — the engine is a process-lifetime singleton.
///
/// The engine will:
/// - Open (or create) the SQLite database at `config.data_dir`.
/// - Start the librqbit BitTorrent session with DHT, trackers, etc.
/// - Restore the previous session's torrents from SQLite.
/// - Launch background polling and resume-save tasks.
pub async fn initialize_engine(config: EngineConfig) -> anyhow::Result<()> {
    TorrentEngine::init(config)
        .await
        .context("Failed to initialise TorStream engine")
}

/// Shut down the engine cleanly.
///
/// Saves all pending resume data, flushes the session state, and cancels
/// background tasks. Call this when the app is being suspended or terminated.
pub async fn shutdown_engine() -> anyhow::Result<()> {
    get_engine()
        .context("Engine not initialised")?
        .shutdown()
        .await;
    Ok(())
}

// ── Torrent management ─────────────────────────────────────────────────────────

/// Add a torrent from a magnet URI.
///
/// Returns the [`TorrentId`] assigned to the new torrent. The torrent begins
/// in `FetchingMetadata` state if the info-dictionary is not yet available.
///
/// # Errors
/// - [`EngineError::InvalidMagnet`] if the URI is malformed.
/// - [`EngineError::SessionError`] if the session rejects the torrent.
pub async fn add_magnet(magnet_uri: String) -> anyhow::Result<u64> {
    get_engine()
        .context("Engine not initialised")?
        .add_magnet(magnet_uri)
        .await
        .context("Failed to add magnet")
}

/// Add a torrent from the raw bytes of a `.torrent` file.
///
/// Returns the [`TorrentId`] assigned to the new torrent.
///
/// # Errors
/// - [`EngineError::InvalidTorrentFile`] if the bytes are not a valid .torrent.
pub async fn add_torrent_file(data: Vec<u8>) -> anyhow::Result<u64> {
    get_engine()
        .context("Engine not initialised")?
        .add_torrent_file(data)
        .await
        .context("Failed to add torrent file")
}

/// Pause a downloading or seeding torrent.
///
/// The torrent's status transitions to `Paused` and the change is persisted
/// to SQLite. No pieces are downloaded while paused.
pub async fn pause_torrent(id: u64) -> anyhow::Result<()> {
    get_engine()
        .context("Engine not initialised")?
        .pause_torrent(id)
        .await
        .context(format!("Failed to pause torrent id={id}"))
}

/// Resume a paused torrent.
///
/// The torrent re-joins the active download queue. Its status transitions to
/// `Downloading` (or `Seeding` if already complete).
pub async fn resume_torrent(id: u64) -> anyhow::Result<()> {
    get_engine()
        .context("Engine not initialised")?
        .resume_torrent(id)
        .await
        .context(format!("Failed to resume torrent id={id}"))
}

/// Remove a torrent from the session.
///
/// If `delete_files` is `true`, the downloaded files are permanently deleted.
/// The torrent record is removed from SQLite.
pub async fn remove_torrent(id: u64, delete_files: bool) -> anyhow::Result<()> {
    get_engine()
        .context("Engine not initialised")?
        .remove_torrent(id, delete_files)
        .await
        .context(format!("Failed to remove torrent id={id}"))
}

// ── Status queries ─────────────────────────────────────────────────────────────

/// Get the current status of a single torrent.
///
/// Returns a [`TorrentInfo`] snapshot. For live stats, prefer subscribing to
/// the event stream via `torrent_events()` in the FRB bridge.
pub async fn get_torrent_status(id: u64) -> anyhow::Result<TorrentInfo> {
    get_engine()
        .context("Engine not initialised")?
        .get_torrent_status(id)
        .await
        .context(format!("Failed to get status for torrent id={id}"))
}

/// Get the current status of every managed torrent.
///
/// Returns an empty `Vec` if no torrents are managed.
pub async fn get_all_torrents() -> anyhow::Result<Vec<TorrentInfo>> {
    Ok(get_engine()
        .context("Engine not initialised")?
        .get_all_torrents()
        .await)
}

/// Get file metadata for a single file within a torrent.
///
/// The returned [`TorrentFileInfo`] contains the piece length, total piece
/// count, file byte range, and file size required by the streaming engine to
/// initialise a pipeline.
pub async fn get_torrent_file_info(
    id: u64,
    file_index: u32,
) -> anyhow::Result<crate::models::TorrentFileInfo> {
    get_engine()
        .context("Engine not initialised")?
        .file_info(id, file_index)
        .await
        .context(format!("Failed to get file info for torrent id={id}, file={file_index}"))
}

// ── Resume data ────────────────────────────────────────────────────────────────

/// Explicitly persist resume data for a single torrent to SQLite.
///
/// Resume data is also saved automatically every 60 seconds and on
/// `shutdown_engine()`, so this function is only needed for custom save points.
pub async fn save_resume_data(id: u64) -> anyhow::Result<()> {
    get_engine()
        .context("Engine not initialised")?
        .save_resume_data(id)
        .await
        .context(format!("Failed to save resume data for id={id}"))
}

/// Load and return all torrent IDs from the previous session's SQLite record.
///
/// The engine automatically restores the session on `initialize_engine()`.
/// Call this if you need the list of previously managed IDs for UI display
/// before the polling loop has populated in-memory state.
pub async fn restore_resume_data() -> anyhow::Result<Vec<u64>> {
    get_engine()
        .context("Engine not initialised")?
        .restore_resume_data()
        .await
        .context("Failed to restore resume data")
}

// ── Event stream ───────────────────────────────────────────────────────────────

/// Subscribe to the engine event bus.
///
/// Returns a `tokio::sync::broadcast::Receiver` that yields [`EngineEvent`]
/// values. The FRB bridge wraps this in a `StreamSink` for Dart consumption.
///
/// Use this to drive real-time UI updates without polling.
pub fn subscribe_events() -> tokio::sync::broadcast::Receiver<EngineEvent> {
    // If the engine isn't initialised yet, create a dummy channel that
    // will immediately be replaced when init is called.
    match get_engine() {
        Ok(engine) => engine.subscribe(),
        Err(_) => {
            let (_, rx) = tokio::sync::broadcast::channel(1);
            rx
        }
    }
}

/// Open an async file stream for reading torrent media data with sequential piece prioritization.
pub async fn open_stream(id: u64, file_index: u32) -> anyhow::Result<Box<dyn crate::session::handle::TorrentStreamReader>> {
    let engine = get_engine().context("Engine not initialised")?;
    let handle = engine.session.get(id)?;
    let info = handle
        .file_info(file_index as usize)
        .ok_or_else(|| anyhow::anyhow!("File info not found for torrent id={}, file={}", id, file_index))?;

    handle.stream(info.file_index as usize).await
}

