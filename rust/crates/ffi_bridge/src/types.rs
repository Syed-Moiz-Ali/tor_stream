//! FFI-safe types shared between Rust and Dart.

use flutter_rust_bridge::frb;
use torrent_engine::TorrentInfo;
use metadata_engine::models as meta;
use streaming_engine::models as stream;
use performance_engine::models as perf;
use reliability_engine::models as rel;
use download_manager::models as dl;
use media_enhancement::models as enh;
use search_engine::models as search;

// ── Phase 1: Diagnostics ──────────────────────────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct EngineInfo {
    pub version:    String,
    pub build_mode: String,
    pub phase:      u32,
}

// ── Phase 2: Engine configuration & Torrent status ────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbEngineConfig {
    pub download_dir: String,
    pub data_dir: String,
    pub listen_port: i32,
    pub max_connections: i32,
    pub upload_rate_limit: i64,
    pub download_rate_limit: i64,
    pub dht_enabled: bool,
    pub lsd_enabled: bool,
    pub upnp_enabled: bool,
    pub natpmp_enabled: bool,
    pub anonymous_mode: bool,
    pub cache_size_mb: i32,
}

impl Default for FrbEngineConfig {
    fn default() -> Self {
        Self {
            download_dir:        String::new(),
            data_dir:            String::new(),
            listen_port:         6881,
            max_connections:     200,
            upload_rate_limit:   0,
            download_rate_limit: 0,
            dht_enabled:         true,
            lsd_enabled:         true,
            upnp_enabled:        true,
            natpmp_enabled:      true,
            anonymous_mode:      false,
            cache_size_mb:       64,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FrbTorrentStatus {
    Queued,
    Checking,
    FetchingMetadata,
    Downloading,
    Seeding,
    Paused,
    Error,
}

impl From<torrent_engine::TorrentStatus> for FrbTorrentStatus {
    fn from(s: torrent_engine::TorrentStatus) -> Self {
        use torrent_engine::TorrentStatus as S;
        match s {
            S::Queued           => Self::Queued,
            S::Checking         => Self::Checking,
            S::FetchingMetadata => Self::FetchingMetadata,
            S::Downloading      => Self::Downloading,
            S::Seeding          => Self::Seeding,
            S::Paused           => Self::Paused,
            S::Error            => Self::Error,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbTorrentInfo {
    pub id: u64,
    pub info_hash: String,
    pub name: Option<String>,
    pub status: FrbTorrentStatus,
    pub progress: f64,
    pub download_rate: i64,
    pub upload_rate: i64,
    pub total_bytes: i64,
    pub downloaded_bytes: i64,
    pub num_peers: i32,
    pub save_path: String,
    pub added_at_ms: i64,
}

impl From<TorrentInfo> for FrbTorrentInfo {
    fn from(t: TorrentInfo) -> Self {
        Self {
            id:               t.id,
            info_hash:        t.info_hash,
            name:             t.name,
            status:           FrbTorrentStatus::from(t.status),
            progress:         t.progress,
            download_rate:    t.download_rate as i64,
            upload_rate:      t.upload_rate   as i64,
            total_bytes:      t.total_bytes   as i64,
            downloaded_bytes: t.downloaded_bytes as i64,
            num_peers:        t.num_peers as i32,
            save_path:        t.save_path,
            added_at_ms:      t.added_at_ms,
        }
    }
}

// ── Phase 3: Metadata Engine Types ────────────────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbRawFileEntry {
    pub index: u32,
    pub path: String,
    pub size: i64,
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbVideoStreamInfo {
    pub width: u32,
    pub height: u32,
    pub codec: String,
    pub frame_rate: f32,
    pub duration_seconds: f64,
    pub bitrate: i64,
}

impl From<meta::VideoStreamInfo> for FrbVideoStreamInfo {
    fn from(v: meta::VideoStreamInfo) -> Self {
        Self {
            width: v.width,
            height: v.height,
            codec: v.codec,
            frame_rate: v.frame_rate,
            duration_seconds: v.duration_seconds,
            bitrate: v.bitrate as i64,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbAudioTrack {
    pub index: u32,
    pub language: String,
    pub title: String,
    pub codec: String,
    pub channels: u32,
    pub bitrate: i64,
}

impl From<meta::AudioTrack> for FrbAudioTrack {
    fn from(a: meta::AudioTrack) -> Self {
        Self {
            index: a.index,
            language: a.language,
            title: a.title,
            codec: a.codec,
            channels: a.channels,
            bitrate: a.bitrate as i64,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbSubtitleTrack {
    pub index: u32,
    pub language: String,
    pub title: String,
    pub format: String,
    pub is_external: bool,
    pub is_forced: bool,
    pub is_default: bool,
    pub file_path: Option<String>,
}

impl From<meta::SubtitleTrack> for FrbSubtitleTrack {
    fn from(s: meta::SubtitleTrack) -> Self {
        Self {
            index: s.index,
            language: s.language,
            title: s.title,
            format: s.format,
            is_external: s.is_external,
            is_forced: s.is_forced,
            is_default: s.is_default,
            file_path: s.file_path,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbArtwork {
    pub file_index: u32,
    pub path: String,
    pub size: i64,
    pub artwork_type: String,
}

impl From<meta::Artwork> for FrbArtwork {
    fn from(a: meta::Artwork) -> Self {
        Self {
            file_index: a.file_index,
            path: a.path,
            size: a.size as i64,
            artwork_type: format!("{:?}", a.artwork_type),
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbMediaFile {
    pub file_index: u32,
    pub path: String,
    pub file_name: String,
    pub extension: String,
    pub size: i64,
    pub media_type: String,
    pub category: String,
    pub confidence_score: f32,
    pub video_info: Option<FrbVideoStreamInfo>,
    pub audio_tracks: Vec<FrbAudioTrack>,
    pub subtitle_tracks: Vec<FrbSubtitleTrack>,
}

impl From<meta::MediaFile> for FrbMediaFile {
    fn from(f: meta::MediaFile) -> Self {
        Self {
            file_index: f.file_index,
            path: f.path,
            file_name: f.file_name,
            extension: f.extension,
            size: f.size as i64,
            media_type: format!("{:?}", f.media_type),
            category: format!("{:?}", f.category),
            confidence_score: f.confidence_score,
            video_info: f.video_info.map(FrbVideoStreamInfo::from),
            audio_tracks: f.audio_tracks.into_iter().map(FrbAudioTrack::from).collect(),
            subtitle_tracks: f.subtitle_tracks.into_iter().map(FrbSubtitleTrack::from).collect(),
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbTorrentMedia {
    pub torrent_id: u64,
    pub category: String,
    pub primary_video: Option<FrbMediaFile>,
    pub videos: Vec<FrbMediaFile>,
    pub audio_files: Vec<FrbMediaFile>,
    pub subtitles: Vec<FrbSubtitleTrack>,
    pub artwork: Vec<FrbArtwork>,
    pub extras: Vec<FrbMediaFile>,
    pub samples: Vec<FrbMediaFile>,
    pub total_size: i64,
    pub file_count: usize,
}

impl From<meta::TorrentMedia> for FrbTorrentMedia {
    fn from(m: meta::TorrentMedia) -> Self {
        Self {
            torrent_id: m.torrent_id,
            category: format!("{:?}", m.category),
            primary_video: m.primary_video.map(FrbMediaFile::from),
            videos: m.videos.into_iter().map(FrbMediaFile::from).collect(),
            audio_files: m.audio_files.into_iter().map(FrbMediaFile::from).collect(),
            subtitles: m.subtitles.into_iter().map(FrbSubtitleTrack::from).collect(),
            artwork: m.artwork.into_iter().map(FrbArtwork::from).collect(),
            extras: m.extras.into_iter().map(FrbMediaFile::from).collect(),
            samples: m.samples.into_iter().map(FrbMediaFile::from).collect(),
            total_size: m.total_size as i64,
            file_count: m.file_count,
        }
    }
}

// ── Phase 4: Adaptive Streaming Engine Types ──────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbBufferStatus {
    pub torrent_id: u64,
    pub file_index: u32,
    pub current_position_bytes: i64,
    pub buffered_bytes: i64,
    pub required_startup_bytes: i64,
    pub read_ahead_bytes: i64,
    pub buffer_health_ratio: f32,
    pub is_buffering: bool,
    pub is_ready: bool,
}

impl From<stream::BufferStatus> for FrbBufferStatus {
    fn from(b: stream::BufferStatus) -> Self {
        Self {
            torrent_id: b.torrent_id,
            file_index: b.file_index,
            current_position_bytes: b.current_position_bytes as i64,
            buffered_bytes: b.buffered_bytes as i64,
            required_startup_bytes: b.required_startup_bytes as i64,
            read_ahead_bytes: b.read_ahead_bytes as i64,
            buffer_health_ratio: b.buffer_health_ratio,
            is_buffering: b.is_buffering,
            is_ready: b.is_ready,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbCacheStatus {
    pub memory_used_bytes: i64,
    pub memory_capacity_bytes: i64,
    pub pinned_pieces_count: usize,
    pub disk_used_bytes: i64,
    pub cache_hit_count: i64,
    pub cache_miss_count: i64,
    pub hit_ratio: f32,
}

impl From<stream::CacheStatus> for FrbCacheStatus {
    fn from(c: stream::CacheStatus) -> Self {
        Self {
            memory_used_bytes: c.memory_used_bytes as i64,
            memory_capacity_bytes: c.memory_capacity_bytes as i64,
            pinned_pieces_count: c.pinned_pieces_count,
            disk_used_bytes: c.disk_used_bytes as i64,
            cache_hit_count: c.cache_hit_count as i64,
            cache_miss_count: c.cache_miss_count as i64,
            hit_ratio: c.hit_ratio,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbStreamStatistics {
    pub torrent_id: u64,
    pub file_index: u32,
    pub playback_state: String,
    pub current_bitrate_bps: i64,
    pub download_speed_bps: i64,
    pub startup_latency_ms: i64,
    pub total_buffer_stalls: u32,
    pub total_bytes_streamed: i64,
    pub read_ahead_seconds: f32,
}

impl From<stream::StreamStatistics> for FrbStreamStatistics {
    fn from(s: stream::StreamStatistics) -> Self {
        Self {
            torrent_id: s.torrent_id,
            file_index: s.file_index,
            playback_state: format!("{:?}", s.playback_state),
            current_bitrate_bps: s.current_bitrate_bps as i64,
            download_speed_bps: s.download_speed_bps as i64,
            startup_latency_ms: s.startup_latency_ms as i64,
            total_buffer_stalls: s.total_buffer_stalls,
            total_bytes_streamed: s.total_bytes_streamed as i64,
            read_ahead_seconds: s.read_ahead_seconds,
        }
    }
}

// ── Phase 6: Performance Engine Types ─────────────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbPerformanceMetrics {
    pub startup_time_ms: i64,
    pub seek_time_ms: i64,
    pub buffer_recovery_time_ms: i64,
    pub cache_hit_rate: f32,
    pub active_peer_count: u32,
    pub avg_download_speed_bps: i64,
    pub avg_upload_speed_bps: i64,
    pub estimated_cpu_usage_pct: f32,
    pub allocated_memory_mb: u32,
    pub disk_throughput_mbps: f32,
}

impl From<perf::PerformanceMetrics> for FrbPerformanceMetrics {
    fn from(p: perf::PerformanceMetrics) -> Self {
        Self {
            startup_time_ms: p.startup_time_ms as i64,
            seek_time_ms: p.seek_time_ms as i64,
            buffer_recovery_time_ms: p.buffer_recovery_time_ms as i64,
            cache_hit_rate: p.cache_hit_rate,
            active_peer_count: p.active_peer_count,
            avg_download_speed_bps: p.avg_download_speed_bps as i64,
            avg_upload_speed_bps: p.avg_upload_speed_bps as i64,
            estimated_cpu_usage_pct: p.estimated_cpu_usage_pct,
            allocated_memory_mb: p.allocated_memory_mb,
            disk_throughput_mbps: p.disk_throughput_mbps,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbProfilerMetrics {
    pub scheduler_latency_us: i64,
    pub disk_read_latency_us: i64,
    pub read_stream_latency_us: i64,
    pub jni_overhead_us: i64,
    pub cache_efficiency_pct: f32,
    pub buffer_stalls_count: u32,
}

impl From<perf::ProfilerMetrics> for FrbProfilerMetrics {
    fn from(p: perf::ProfilerMetrics) -> Self {
        Self {
            scheduler_latency_us: p.scheduler_latency_us as i64,
            disk_read_latency_us: p.disk_read_latency_us as i64,
            read_stream_latency_us: p.read_stream_latency_us as i64,
            jni_overhead_us: p.jni_overhead_us as i64,
            cache_efficiency_pct: p.cache_efficiency_pct,
            buffer_stalls_count: p.buffer_stalls_count,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbBenchmarkSuiteResult {
    pub total_profiles_tested: usize,
    pub passed_profiles: usize,
    pub average_startup_ms: i64,
    pub average_seek_ms: i64,
    pub max_memory_mb: u32,
}

impl From<perf::BenchmarkSuiteResult> for FrbBenchmarkSuiteResult {
    fn from(b: perf::BenchmarkSuiteResult) -> Self {
        Self {
            total_profiles_tested: b.total_profiles_tested,
            passed_profiles: b.passed_profiles,
            average_startup_ms: b.average_startup_ms as i64,
            average_seek_ms: b.average_seek_ms as i64,
            max_memory_mb: b.max_memory_mb,
        }
    }
}

// ── Phase 7: Reliability Engine Types ─────────────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbSessionSnapshot {
    pub torrent_id: u64,
    pub info_hash: String,
    pub magnet_uri: Option<String>,
    pub file_index: u32,
    pub playback_position_bytes: i64,
    pub total_bytes: i64,
    pub selected_audio_track: u32,
    pub selected_subtitle_track: u32,
    pub playback_speed: f32,
    pub is_playing: bool,
    pub last_active_timestamp_ms: i64,
}

impl From<rel::SessionSnapshot> for FrbSessionSnapshot {
    fn from(s: rel::SessionSnapshot) -> Self {
        Self {
            torrent_id: s.torrent_id,
            info_hash: s.info_hash,
            magnet_uri: s.magnet_uri,
            file_index: s.file_index,
            playback_position_bytes: s.playback_position_bytes as i64,
            total_bytes: s.total_bytes as i64,
            selected_audio_track: s.selected_audio_track,
            selected_subtitle_track: s.selected_subtitle_track,
            playback_speed: s.playback_speed,
            is_playing: s.is_playing,
            last_active_timestamp_ms: s.last_active_timestamp_ms,
        }
    }
}

impl From<FrbSessionSnapshot> for rel::SessionSnapshot {
    fn from(f: FrbSessionSnapshot) -> Self {
        Self {
            torrent_id: f.torrent_id,
            info_hash: f.info_hash,
            magnet_uri: f.magnet_uri,
            file_index: f.file_index,
            playback_position_bytes: f.playback_position_bytes as u64,
            total_bytes: f.total_bytes as u64,
            selected_audio_track: f.selected_audio_track,
            selected_subtitle_track: f.selected_subtitle_track,
            playback_speed: f.playback_speed,
            is_playing: f.is_playing,
            last_active_timestamp_ms: f.last_active_timestamp_ms,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbHealthStatus {
    pub is_healthy: bool,
    pub available_storage_bytes: i64,
    pub storage_warning: bool,
    pub available_ram_mb: u32,
    pub is_database_ok: bool,
    pub is_network_connected: bool,
    pub active_torrents_count: usize,
}

impl From<rel::HealthStatus> for FrbHealthStatus {
    fn from(h: rel::HealthStatus) -> Self {
        Self {
            is_healthy: h.is_healthy,
            available_storage_bytes: h.available_storage_bytes as i64,
            storage_warning: h.storage_warning,
            available_ram_mb: h.available_ram_mb,
            is_database_ok: h.is_database_ok,
            is_network_connected: h.is_network_connected,
            active_torrents_count: h.active_torrents_count,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbStorageReport {
    pub total_space_bytes: i64,
    pub free_space_bytes: i64,
    pub cache_size_bytes: i64,
    pub corrupted_pieces_repaired: u32,
    pub database_vacuumed: bool,
}

impl From<rel::StorageReport> for FrbStorageReport {
    fn from(s: rel::StorageReport) -> Self {
        Self {
            total_space_bytes: s.total_space_bytes as i64,
            free_space_bytes: s.free_space_bytes as i64,
            cache_size_bytes: s.cache_size_bytes as i64,
            corrupted_pieces_repaired: s.corrupted_pieces_repaired,
            database_vacuumed: s.database_vacuumed,
        }
    }
}

// ── Phase 8: Download Manager & Media Library Types ────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbDownloadTask {
    pub id: u64,
    pub torrent_id: u64,
    pub title: String,
    pub save_path: String,
    pub total_bytes: i64,
    pub downloaded_bytes: i64,
    pub progress: f32,
    pub download_speed_bps: i64,
    pub priority: String,
    pub state: String,
    pub added_at_ms: i64,
}

impl From<dl::DownloadTask> for FrbDownloadTask {
    fn from(t: dl::DownloadTask) -> Self {
        Self {
            id: t.id,
            torrent_id: t.torrent_id,
            title: t.title,
            save_path: t.save_path,
            total_bytes: t.total_bytes as i64,
            downloaded_bytes: t.downloaded_bytes as i64,
            progress: t.progress,
            download_speed_bps: t.download_speed_bps as i64,
            priority: format!("{:?}", t.priority),
            state: format!("{:?}", t.state),
            added_at_ms: t.added_at_ms,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbLibraryItem {
    pub id: u64,
    pub torrent_id: u64,
    pub title: String,
    pub category: String,
    pub primary_file_index: u32,
    pub total_bytes: i64,
    pub artwork_path: Option<String>,
    pub is_favorite: bool,
    pub date_added_ms: i64,
}

impl From<dl::LibraryItem> for FrbLibraryItem {
    fn from(i: dl::LibraryItem) -> Self {
        Self {
            id: i.id,
            torrent_id: i.torrent_id,
            title: i.title,
            category: format!("{:?}", i.category),
            primary_file_index: i.primary_file_index,
            total_bytes: i.total_bytes as i64,
            artwork_path: i.artwork_path,
            is_favorite: i.is_favorite,
            date_added_ms: i.date_added_ms,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbContinueWatchingItem {
    pub id: u64,
    pub torrent_id: u64,
    pub file_index: u32,
    pub title: String,
    pub artwork_path: Option<String>,
    pub position_ms: i64,
    pub duration_ms: i64,
    pub progress_pct: f32,
    pub last_played_ms: i64,
}

impl From<dl::ContinueWatchingItem> for FrbContinueWatchingItem {
    fn from(c: dl::ContinueWatchingItem) -> Self {
        Self {
            id: c.id,
            torrent_id: c.torrent_id,
            file_index: c.file_index,
            title: c.title,
            artwork_path: c.artwork_path,
            position_ms: c.position_ms as i64,
            duration_ms: c.duration_ms as i64,
            progress_pct: c.progress_pct,
            last_played_ms: c.last_played_ms,
        }
    }
}

// ── Phase 9: Media Enhancement Engine Types ───────────────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbSubtitleConfig {
    pub delay_ms: i64,
    pub font_size_pt: u32,
    pub color_hex: String,
    pub background_color_hex: String,
    pub outline_color_hex: String,
    pub shadow_enabled: bool,
    pub encoding: String,
}

impl From<enh::SubtitleConfig> for FrbSubtitleConfig {
    fn from(s: enh::SubtitleConfig) -> Self {
        Self {
            delay_ms: s.delay_ms,
            font_size_pt: s.font_size_pt,
            color_hex: s.color_hex,
            background_color_hex: s.background_color_hex,
            outline_color_hex: s.outline_color_hex,
            shadow_enabled: s.shadow_enabled,
            encoding: s.encoding,
        }
    }
}

impl From<FrbSubtitleConfig> for enh::SubtitleConfig {
    fn from(f: FrbSubtitleConfig) -> Self {
        Self {
            delay_ms: f.delay_ms,
            font_size_pt: f.font_size_pt,
            color_hex: f.color_hex,
            background_color_hex: f.background_color_hex,
            outline_color_hex: f.outline_color_hex,
            shadow_enabled: f.shadow_enabled,
            encoding: f.encoding,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbMediaChapter {
    pub index: usize,
    pub title: String,
    pub start_ms: i64,
    pub end_ms: i64,
}

impl From<enh::MediaChapter> for FrbMediaChapter {
    fn from(c: enh::MediaChapter) -> Self {
        Self {
            index: c.index,
            title: c.title,
            start_ms: c.start_ms as i64,
            end_ms: c.end_ms as i64,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbMediaThumbnail {
    pub timestamp_ms: i64,
    pub image_path: String,
    pub width: u32,
    pub height: u32,
}

impl From<enh::MediaThumbnail> for FrbMediaThumbnail {
    fn from(t: enh::MediaThumbnail) -> Self {
        Self {
            timestamp_ms: t.timestamp_ms as i64,
            image_path: t.image_path,
            width: t.width,
            height: t.height,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbFullMediaInfo {
    pub container: String,
    pub duration_seconds: f64,
    pub video_codec: String,
    pub resolution_width: u32,
    pub resolution_height: u32,
    pub bitrate_bps: i64,
    pub frame_rate: f32,
    pub is_hdr: bool,
    pub color_space: String,
    pub aspect_ratio: String,
    pub total_audio_tracks: usize,
    pub total_subtitle_tracks: usize,
    pub total_chapters: usize,
}

impl From<enh::FullMediaInfo> for FrbFullMediaInfo {
    fn from(m: enh::FullMediaInfo) -> Self {
        Self {
            container: m.container,
            duration_seconds: m.duration_seconds,
            video_codec: m.video_codec,
            resolution_width: m.resolution_width,
            resolution_height: m.resolution_height,
            bitrate_bps: m.bitrate_bps as i64,
            frame_rate: m.frame_rate,
            is_hdr: m.is_hdr,
            color_space: m.color_space,
            aspect_ratio: m.aspect_ratio,
            total_audio_tracks: m.total_audio_tracks,
            total_subtitle_tracks: m.total_subtitle_tracks,
            total_chapters: m.total_chapters,
        }
    }
}

// ── Phase 10: Search, Indexing & Discovery Engine Types ────────────────────────

#[frb(non_opaque)]
#[derive(Debug, Clone, Default)]
pub struct FrbSearchFilters {
    pub category: Option<String>,
    pub status: Option<String>,
    pub is_favorite: Option<bool>,
    pub continue_watching: Option<bool>,
    pub resolution: Option<String>,
    pub audio_language: Option<String>,
}

impl From<FrbSearchFilters> for search::SearchFilters {
    fn from(f: FrbSearchFilters) -> Self {
        Self {
            category: f.category,
            status: f.status,
            is_favorite: f.is_favorite,
            continue_watching: f.continue_watching,
            resolution: f.resolution,
            audio_language: f.audio_language,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbSortOptions {
    pub sort_by: String, // Title, DateAdded, LastPlayed, Progress, Duration, FileSize
    pub descending: bool,
}

impl From<FrbSortOptions> for search::SortOptions {
    fn from(s: FrbSortOptions) -> Self {
        let sort_by = match s.sort_by.as_str() {
            "Title" => search::SortBy::Title,
            "LastPlayed" => search::SortBy::LastPlayed,
            "Progress" => search::SortBy::Progress,
            "Duration" => search::SortBy::Duration,
            "FileSize" => search::SortBy::FileSize,
            _ => search::SortBy::DateAdded,
        };
        let direction = if s.descending {
            search::SortDirection::Descending
        } else {
            search::SortDirection::Ascending
        };
        Self { sort_by, direction }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct FrbSearchResultItem {
    pub torrent_id: u64,
    pub title: String,
    pub category: String,
    pub file_name: String,
    pub resolution: String,
    pub codec: String,
    pub total_bytes: i64,
    pub progress: f32,
    pub relevance_score: f32,
}

impl From<search::SearchResultItem> for FrbSearchResultItem {
    fn from(s: search::SearchResultItem) -> Self {
        Self {
            torrent_id: s.torrent_id,
            title: s.title,
            category: s.category,
            file_name: s.file_name,
            resolution: s.resolution,
            codec: s.codec,
            total_bytes: s.total_bytes as i64,
            progress: s.progress,
            relevance_score: s.relevance_score,
        }
    }
}

impl From<FrbSearchResultItem> for search::SearchResultItem {
    fn from(f: FrbSearchResultItem) -> Self {
        Self {
            torrent_id: f.torrent_id,
            title: f.title,
            category: f.category,
            file_name: f.file_name,
            resolution: f.resolution,
            codec: f.codec,
            total_bytes: f.total_bytes as u64,
            progress: f.progress,
            relevance_score: f.relevance_score,
        }
    }
}
