//! Public Rust API for download_manager.

use std::path::PathBuf;
use std::sync::OnceLock;

use crate::bandwidth::BandwidthManager;
use crate::continue_watching::ContinueWatchingManager;
use crate::library::MediaLibrary;
use crate::models::{
    BandwidthSettings, ContinueWatchingItem, DownloadState, DownloadTask, LibraryItem,
    QueuePriority,
};
use crate::persistence::LibraryStore;
use crate::queue::DownloadQueue;

static STORE: OnceLock<LibraryStore> = OnceLock::new();
static QUEUE: OnceLock<DownloadQueue> = OnceLock::new();
static LIBRARY: OnceLock<MediaLibrary> = OnceLock::new();
static CONTINUE: OnceLock<ContinueWatchingManager> = OnceLock::new();
static BANDWIDTH: OnceLock<BandwidthManager> = OnceLock::new();

fn get_db_path() -> PathBuf {
    let base = std::env::temp_dir().join("tor_stream_data");
    base.join("media_library.db")
}

fn get_store() -> &'static LibraryStore {
    STORE.get_or_init(|| {
        let db_path = get_db_path();
        LibraryStore::open(&db_path).unwrap()
    })
}

fn get_queue() -> &'static DownloadQueue {
    QUEUE.get_or_init(|| DownloadQueue::new(get_store().clone(), 3).unwrap())
}

fn get_library_inst() -> &'static MediaLibrary {
    LIBRARY.get_or_init(|| MediaLibrary::new(get_store().clone()))
}

fn get_continue_inst() -> &'static ContinueWatchingManager {
    CONTINUE.get_or_init(|| ContinueWatchingManager::new(get_store().clone()))
}

fn get_bandwidth_inst() -> &'static BandwidthManager {
    BANDWIDTH.get_or_init(BandwidthManager::new)
}

/// Enqueue a download task.
pub fn start_download(torrent_id: u64, title: String, save_path: String, total_bytes: u64) -> anyhow::Result<u64> {
    let id = torrent_id;
    let task = DownloadTask {
        id,
        torrent_id,
        title,
        save_path,
        total_bytes,
        downloaded_bytes: 0,
        progress: 0.0,
        download_speed_bps: 0,
        priority: QueuePriority::Normal,
        state: DownloadState::Queued,
        added_at_ms: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_millis() as i64)
            .unwrap_or(0),
    };
    get_queue().enqueue_task(task)?;
    Ok(id)
}

pub fn pause_download(id: u64) -> anyhow::Result<()> {
    get_queue().pause_task(id)?;
    Ok(())
}

pub fn resume_download(id: u64) -> anyhow::Result<()> {
    get_queue().resume_task(id)?;
    Ok(())
}

pub fn cancel_download(id: u64) -> anyhow::Result<()> {
    get_queue().cancel_task(id)?;
    Ok(())
}

pub fn delete_download(id: u64) -> anyhow::Result<()> {
    get_queue().cancel_task(id)?;
    Ok(())
}

pub fn get_library() -> anyhow::Result<Vec<LibraryItem>> {
    Ok(get_library_inst().get_all()?)
}

pub fn search_library(query: String) -> anyhow::Result<Vec<LibraryItem>> {
    Ok(get_library_inst().search(&query)?)
}

pub fn get_continue_watching() -> anyhow::Result<Vec<ContinueWatchingItem>> {
    Ok(get_continue_inst().get_items()?)
}

pub fn add_favorite(torrent_id: u64) -> anyhow::Result<()> {
    get_library_inst().toggle_favorite(torrent_id)?;
    Ok(())
}

pub fn remove_favorite(torrent_id: u64) -> anyhow::Result<()> {
    get_library_inst().toggle_favorite(torrent_id)?;
    Ok(())
}

pub fn set_bandwidth_limit(download_limit_bps: u64, upload_limit_bps: u64, wifi_only: bool) -> anyhow::Result<()> {
    get_bandwidth_inst().set_limits(BandwidthSettings {
        download_limit_bps,
        upload_limit_bps,
        wifi_only,
        max_active_downloads: 3,
    });
    Ok(())
}
