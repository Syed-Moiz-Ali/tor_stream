//! Public API bridge for metadata engine.

use std::path::PathBuf;
use std::sync::OnceLock;
use anyhow::Context;

use crate::analyzer::MetadataAnalyzer;
use crate::models::{Artwork, AudioTrack, MediaFile, SubtitleTrack, TorrentMedia};
use crate::parser::RawFileEntry;

static ANALYZER: OnceLock<MetadataAnalyzer> = OnceLock::new();

fn get_analyzer() -> &'static MetadataAnalyzer {
    ANALYZER.get_or_init(MetadataAnalyzer::new)
}

/// Scan a torrent's files and build full [`TorrentMedia`].
pub fn scan_torrent(
    torrent_id: u64,
    file_entries: Vec<RawFileEntry>,
    base_dir: Option<String>,
) -> anyhow::Result<TorrentMedia> {
    let p = base_dir.map(PathBuf::from);
    get_analyzer()
        .analyze(torrent_id, &file_entries, p.as_deref())
        .context("Failed to scan torrent metadata")
}

/// Alias for scan_torrent (without base directory).
pub fn analyze_media(
    torrent_id: u64,
    file_entries: Vec<RawFileEntry>,
) -> anyhow::Result<TorrentMedia> {
    scan_torrent(torrent_id, file_entries, None)
}

/// Retrieve cached media analysis for a torrent.
pub fn get_media(torrent_id: u64) -> anyhow::Result<TorrentMedia> {
    get_analyzer()
        .cache()
        .get(torrent_id)
        .ok_or_else(|| anyhow::anyhow!("No metadata found for torrent_id={}", torrent_id))
}

/// Get primary video file for a torrent.
pub fn get_main_video(torrent_id: u64) -> anyhow::Result<Option<MediaFile>> {
    let media = get_media(torrent_id)?;
    Ok(media.primary_video)
}

/// Get all subtitle tracks for a torrent.
pub fn get_subtitles(torrent_id: u64) -> anyhow::Result<Vec<SubtitleTrack>> {
    let media = get_media(torrent_id)?;
    Ok(media.subtitles)
}

/// Get all audio tracks from primary video file.
pub fn get_audio_tracks(torrent_id: u64) -> anyhow::Result<Vec<AudioTrack>> {
    let media = get_media(torrent_id)?;
    Ok(media.primary_video.map_or_else(Vec::new, |v| v.audio_tracks))
}

/// Get all artwork entries for a torrent.
pub fn get_artwork(torrent_id: u64) -> anyhow::Result<Vec<Artwork>> {
    let media = get_media(torrent_id)?;
    Ok(media.artwork)
}
