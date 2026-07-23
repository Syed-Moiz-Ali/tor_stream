//! FFI API — Phase 1-10 complete pipeline.

use flutter_rust_bridge::frb;
use download_manager::bridge as dl_engine;
use media_enhancement::bridge as enh_engine;
use metadata_engine::{bridge as meta_engine, RawFileEntry};
use performance_engine::bridge as perf_engine;
use reliability_engine::bridge as rel_engine;
use search_engine::bridge as search_engine_impl;
use streaming_engine::bridge as stream_engine;
use torrent_engine::{bridge as engine, EngineConfig};

use crate::types::{
    EngineInfo, FrbArtwork, FrbAudioTrack, FrbBenchmarkSuiteResult, FrbBufferStatus,
    FrbCacheStatus, FrbContinueWatchingItem, FrbEngineConfig, FrbHealthStatus, FrbLibraryItem,
    FrbMediaChapter, FrbMediaFile, FrbMediaThumbnail, FrbPerformanceMetrics, FrbProfilerMetrics,
    FrbRawFileEntry, FrbSearchFilters, FrbSearchResultItem, FrbSessionSnapshot, FrbSortOptions,
    FrbStorageReport, FrbStreamStatistics, FrbSubtitleConfig, FrbSubtitleTrack, FrbTorrentInfo,
    FrbTorrentMedia,
};

// ── Phase 1: Diagnostics ──────────────────────────────────────────────────────

#[frb(init)]
pub fn init_app() {
    torrent_core::logger::init();
    tracing::info!("TorStream engine initialised (Phase 10 Search, Indexing & Discovery Engine)");
}

#[frb(sync)]
pub fn get_engine_info() -> EngineInfo {
    EngineInfo {
        version:    torrent_core::ENGINE_VERSION.to_owned(),
        build_mode: if cfg!(debug_assertions) { "debug".into() } else { "release".into() },
        phase:      10,
    }
}

#[frb(sync)]
pub fn ping() -> bool {
    tracing::debug!("ping");
    true
}

// ── Phase 2: Engine lifecycle & torrent ops ───────────────────────────────────

pub async fn initialize_torrent_engine(config: FrbEngineConfig) -> anyhow::Result<()> {
    let cfg = EngineConfig {
        download_dir:        config.download_dir.into(),
        data_dir:            config.data_dir.into(),
        listen_port:         config.listen_port as u16,
        max_connections:     config.max_connections as u32,
        upload_rate_limit:   config.upload_rate_limit as u64,
        download_rate_limit: config.download_rate_limit as u64,
        dht_enabled:         config.dht_enabled,
        lsd_enabled:         config.lsd_enabled,
        upnp_enabled:        config.upnp_enabled,
        natpmp_enabled:      config.natpmp_enabled,
        anonymous_mode:      config.anonymous_mode,
        cache_size_mb:       config.cache_size_mb as u32,
    };
    engine::initialize_engine(cfg).await
}

pub async fn shutdown_torrent_engine() -> anyhow::Result<()> {
    engine::shutdown_engine().await
}

pub async fn add_magnet(magnet_uri: String) -> anyhow::Result<u64> {
    engine::add_magnet(magnet_uri).await
}

pub async fn add_torrent_file(data: Vec<u8>) -> anyhow::Result<u64> {
    engine::add_torrent_file(data).await
}

pub async fn pause_torrent(id: u64) -> anyhow::Result<()> {
    engine::pause_torrent(id).await
}

pub async fn resume_torrent(id: u64) -> anyhow::Result<()> {
    engine::resume_torrent(id).await
}

pub async fn remove_torrent(id: u64, delete_files: bool) -> anyhow::Result<()> {
    engine::remove_torrent(id, delete_files).await
}

pub async fn get_torrent_status(id: u64) -> anyhow::Result<FrbTorrentInfo> {
    engine::get_torrent_status(id)
        .await
        .map(FrbTorrentInfo::from)
}

pub async fn get_all_torrents() -> anyhow::Result<Vec<FrbTorrentInfo>> {
    let all = engine::get_all_torrents().await?;
    Ok(all.into_iter().map(FrbTorrentInfo::from).collect())
}

pub async fn save_resume_data(id: u64) -> anyhow::Result<()> {
    engine::save_resume_data(id).await
}

pub async fn restore_resume_data() -> anyhow::Result<Vec<u64>> {
    engine::restore_resume_data().await
}

// ── Phase 3: Metadata Engine Public APIs ──────────────────────────────────────

pub async fn scan_torrent(
    torrent_id: u64,
    file_entries: Vec<FrbRawFileEntry>,
    base_dir: Option<String>,
) -> anyhow::Result<FrbTorrentMedia> {
    let raw: Vec<RawFileEntry> = file_entries
        .into_iter()
        .map(|f| RawFileEntry {
            index: f.index,
            path: f.path,
            size: f.size as u64,
        })
        .collect();

    let media = meta_engine::scan_torrent(torrent_id, raw, base_dir)?;
    Ok(FrbTorrentMedia::from(media))
}

pub async fn get_media(torrent_id: u64) -> anyhow::Result<FrbTorrentMedia> {
    let media = meta_engine::get_media(torrent_id)?;
    Ok(FrbTorrentMedia::from(media))
}

pub async fn get_primary_video(torrent_id: u64) -> anyhow::Result<Option<FrbMediaFile>> {
    let video = meta_engine::get_main_video(torrent_id)?;
    Ok(video.map(FrbMediaFile::from))
}

pub async fn get_subtitles(torrent_id: u64) -> anyhow::Result<Vec<FrbSubtitleTrack>> {
    let subs = meta_engine::get_subtitles(torrent_id)?;
    Ok(subs.into_iter().map(FrbSubtitleTrack::from).collect())
}

pub async fn get_audio_tracks(torrent_id: u64) -> anyhow::Result<Vec<FrbAudioTrack>> {
    let audio = meta_engine::get_audio_tracks(torrent_id)?;
    Ok(audio.into_iter().map(FrbAudioTrack::from).collect())
}

pub async fn get_artwork(torrent_id: u64) -> anyhow::Result<Vec<FrbArtwork>> {
    let art = meta_engine::get_artwork(torrent_id)?;
    Ok(art.into_iter().map(FrbArtwork::from).collect())
}

// ── Phase 4: Adaptive Streaming Engine Public APIs ────────────────────────────

pub async fn prepare_stream(
    torrent_id: u64,
    file_index: u32,
    file_size: u64,
    piece_length: u32,
    total_pieces: u32,
    file_start_piece: u32,
    file_num_pieces: u32,
) -> anyhow::Result<()> {
    stream_engine::prepare_stream(
        torrent_id,
        file_index,
        file_size,
        piece_length,
        total_pieces,
        file_start_piece,
        file_num_pieces,
    )
    .await
}

pub async fn start_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    stream_engine::start_stream(torrent_id, file_index).await
}

pub async fn pause_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    stream_engine::pause_stream(torrent_id, file_index).await
}

pub async fn resume_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    stream_engine::resume_stream(torrent_id, file_index).await
}

pub async fn seek_stream(
    torrent_id: u64,
    file_index: u32,
    offset_bytes: u64,
) -> anyhow::Result<()> {
    stream_engine::seek_stream(torrent_id, file_index, offset_bytes).await
}

pub async fn stop_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    stream_engine::stop_stream(torrent_id, file_index).await
}

pub async fn get_buffer_status(
    torrent_id: u64,
    file_index: u32,
) -> anyhow::Result<FrbBufferStatus> {
    stream_engine::get_buffer_status(torrent_id, file_index)
        .await
        .map(FrbBufferStatus::from)
}

pub async fn get_cache_status(
    torrent_id: u64,
    file_index: u32,
) -> anyhow::Result<FrbCacheStatus> {
    stream_engine::get_cache_status(torrent_id, file_index)
        .await
        .map(FrbCacheStatus::from)
}

pub async fn get_stream_statistics(
    torrent_id: u64,
    file_index: u32,
) -> anyhow::Result<FrbStreamStatistics> {
    stream_engine::get_stream_statistics(torrent_id, file_index)
        .await
        .map(FrbStreamStatistics::from)
}

// ── Phase 6: Performance Engine Public APIs ───────────────────────────────────

pub async fn get_performance_metrics() -> anyhow::Result<FrbPerformanceMetrics> {
    perf_engine::get_performance_metrics()
        .await
        .map(FrbPerformanceMetrics::from)
}

pub fn get_benchmark_results() -> anyhow::Result<FrbBenchmarkSuiteResult> {
    perf_engine::get_benchmark_results().map(FrbBenchmarkSuiteResult::from)
}

pub async fn reset_profiler() -> anyhow::Result<()> {
    perf_engine::reset_profiler().await
}

pub async fn export_metrics() -> anyhow::Result<FrbProfilerMetrics> {
    perf_engine::export_metrics()
        .await
        .map(FrbProfilerMetrics::from)
}

// ── Phase 7: Reliability Engine Public APIs ───────────────────────────────────

pub fn restore_session() -> anyhow::Result<Option<FrbSessionSnapshot>> {
    let res = rel_engine::restore_session()?;
    Ok(res.map(FrbSessionSnapshot::from))
}

pub fn save_session(snapshot: FrbSessionSnapshot) -> anyhow::Result<()> {
    rel_engine::save_session(snapshot.into())
}

pub fn verify_storage() -> anyhow::Result<FrbStorageReport> {
    rel_engine::verify_storage().map(FrbStorageReport::from)
}

pub fn repair_cache() -> anyhow::Result<FrbStorageReport> {
    rel_engine::repair_cache().map(FrbStorageReport::from)
}

pub fn health_status() -> anyhow::Result<FrbHealthStatus> {
    rel_engine::health_status().map(FrbHealthStatus::from)
}

pub fn backup_now() -> anyhow::Result<String> {
    rel_engine::backup_now()
}

// ── Phase 8: Download Manager & Media Library Public APIs ─────────────────────

pub fn start_download(torrent_id: u64, title: String, save_path: String, total_bytes: i64) -> anyhow::Result<u64> {
    dl_engine::start_download(torrent_id, title, save_path, total_bytes as u64)
}

pub fn pause_download(id: u64) -> anyhow::Result<()> {
    dl_engine::pause_download(id)
}

pub fn resume_download(id: u64) -> anyhow::Result<()> {
    dl_engine::resume_download(id)
}

pub fn cancel_download(id: u64) -> anyhow::Result<()> {
    dl_engine::cancel_download(id)
}

pub fn delete_download(id: u64) -> anyhow::Result<()> {
    dl_engine::delete_download(id)
}

pub fn get_library() -> anyhow::Result<Vec<FrbLibraryItem>> {
    let items = dl_engine::get_library()?;
    Ok(items.into_iter().map(FrbLibraryItem::from).collect())
}

pub fn search_library(query: String) -> anyhow::Result<Vec<FrbLibraryItem>> {
    let items = dl_engine::search_library(query)?;
    Ok(items.into_iter().map(FrbLibraryItem::from).collect())
}

pub fn get_continue_watching() -> anyhow::Result<Vec<FrbContinueWatchingItem>> {
    let items = dl_engine::get_continue_watching()?;
    Ok(items.into_iter().map(FrbContinueWatchingItem::from).collect())
}

pub fn add_favorite(torrent_id: u64) -> anyhow::Result<()> {
    dl_engine::add_favorite(torrent_id)
}

pub fn remove_favorite(torrent_id: u64) -> anyhow::Result<()> {
    dl_engine::remove_favorite(torrent_id)
}

pub fn set_bandwidth_limit(download_limit_bps: i64, upload_limit_bps: i64, wifi_only: bool) -> anyhow::Result<()> {
    dl_engine::set_bandwidth_limit(download_limit_bps as u64, upload_limit_bps as u64, wifi_only)
}

// ── Phase 9: Media Enhancement Engine Public APIs ─────────────────────────────

pub fn load_subtitles(config: FrbSubtitleConfig) -> anyhow::Result<()> {
    enh_engine::load_subtitles(config.into())
}

pub fn change_subtitle(delay_ms: i64) -> anyhow::Result<i64> {
    enh_engine::change_subtitle(delay_ms)
}

pub fn change_audio_track(track_index: u32) -> anyhow::Result<()> {
    enh_engine::change_audio_track(track_index)
}

pub fn generate_thumbnails(duration_seconds: f64, interval_seconds: u32) -> anyhow::Result<Vec<FrbMediaThumbnail>> {
    let list = enh_engine::generate_thumbnails(duration_seconds, interval_seconds)?;
    Ok(list.into_iter().map(FrbMediaThumbnail::from).collect())
}

pub fn get_chapters(duration_seconds: f64) -> anyhow::Result<Vec<FrbMediaChapter>> {
    let list = enh_engine::get_chapters(duration_seconds)?;
    Ok(list.into_iter().map(FrbMediaChapter::from).collect())
}

pub fn set_playback_speed(speed: f32) -> anyhow::Result<f32> {
    enh_engine::set_playback_speed(speed)
}

// ── Phase 10: Search, Indexing & Discovery Engine Public APIs ──────────────────

pub fn search(query: String) -> anyhow::Result<Vec<FrbSearchResultItem>> {
    let list = search_engine_impl::search(query)?;
    Ok(list.into_iter().map(FrbSearchResultItem::from).collect())
}

pub fn filter(items: Vec<FrbSearchResultItem>, filters: FrbSearchFilters) -> anyhow::Result<Vec<FrbSearchResultItem>> {
    let native_items = items.into_iter().map(|i| i.into()).collect();
    let res = search_engine_impl::filter(native_items, filters.into())?;
    Ok(res.into_iter().map(FrbSearchResultItem::from).collect())
}

pub fn sort(items: Vec<FrbSearchResultItem>, options: FrbSortOptions) -> anyhow::Result<Vec<FrbSearchResultItem>> {
    let native_items = items.into_iter().map(|i| i.into()).collect();
    let res = search_engine_impl::sort(native_items, options.into())?;
    Ok(res.into_iter().map(FrbSearchResultItem::from).collect())
}

pub fn create_collection(name: String, description: String) -> anyhow::Result<u64> {
    search_engine_impl::create_collection(name, description)
}

pub fn delete_collection(id: u64) -> anyhow::Result<()> {
    search_engine_impl::delete_collection(id)
}

pub fn add_to_collection(collection_id: u64, torrent_id: u64) -> anyhow::Result<()> {
    search_engine_impl::add_to_collection(collection_id, torrent_id)
}

pub fn remove_from_collection(collection_id: u64, torrent_id: u64) -> anyhow::Result<()> {
    search_engine_impl::remove_from_collection(collection_id, torrent_id)
}
