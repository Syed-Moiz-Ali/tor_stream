//! Metadata analyzer engine.

use std::path::Path;
use std::sync::Arc;
use dashmap::DashMap;
use tracing::{debug, info};

use crate::detector::{classify_artwork, parse_external_subtitle, score_video_file};
use crate::error::{MetadataError, Result};
use crate::ffprobe::inspect_file;
use crate::models::{
    FileCategory, MediaCategory, MediaFile, MediaType, TorrentMedia,
};
use crate::parser::{parse_file_entries, RawFileEntry};

/// In-memory cache for analyzed torrent metadata.
#[derive(Clone, Default)]
pub struct MetadataCache {
    cache: Arc<DashMap<u64, TorrentMedia>>,
}

impl MetadataCache {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn get(&self, torrent_id: u64) -> Option<TorrentMedia> {
        self.cache.get(&torrent_id).map(|r| r.value().clone())
    }

    pub fn insert(&self, media: TorrentMedia) {
        self.cache.insert(media.torrent_id, media);
    }

    pub fn remove(&self, torrent_id: u64) {
        self.cache.remove(&torrent_id);
    }
}

/// Metadata Analyzer logic.
pub struct MetadataAnalyzer {
    cache: MetadataCache,
}

impl MetadataAnalyzer {
    pub fn new() -> Self {
        Self {
            cache: MetadataCache::new(),
        }
    }

    pub fn cache(&self) -> &MetadataCache {
        &self.cache
    }

    /// Analyze a list of file entries for a torrent.
    pub fn analyze(
        &self,
        torrent_id: u64,
        entries: &[RawFileEntry],
        base_dir: Option<&Path>,
    ) -> Result<TorrentMedia> {
        if entries.is_empty() {
            return Err(MetadataError::EmptyTorrent);
        }

        if let Some(cached) = self.cache.get(torrent_id) {
            debug!(torrent_id, "Returning cached metadata analysis");
            return Ok(cached);
        }

        info!(torrent_id, file_count = entries.len(), "Analyzing torrent metadata");

        let mut parsed_files = parse_file_entries(entries);

        let max_video_size = parsed_files
            .iter()
            .filter(|f| f.media_type == MediaType::Video)
            .map(|f| f.size)
            .max()
            .unwrap_or(0);

        let mut videos = Vec::new();
        let mut audio_files = Vec::new();
        let mut subtitles = Vec::new();
        let mut artwork = Vec::new();
        let mut extras = Vec::new();
        let mut samples = Vec::new();

        let total_size: u64 = entries.iter().map(|e| e.size).sum();

        for file in &mut parsed_files {
            match file.media_type {
                MediaType::Video => {
                    let file_path = base_dir.map(|b| b.join(&file.path));

                    if let Some(p) = file_path {
                        if let Ok(Some(ff_res)) = inspect_file(&p) {
                            file.video_info = ff_res.video_info;
                            file.audio_tracks = ff_res.audio_tracks;
                            for sub in ff_res.subtitle_tracks {
                                subtitles.push(sub);
                            }
                        }
                    }

                    let (cat, score) = score_video_file(
                        &file.path,
                        file.size,
                        max_video_size,
                        &file.extension,
                        file.video_info.as_ref(),
                    );
                    file.category = cat;
                    file.confidence_score = score;

                    match cat {
                        FileCategory::MainFeature | FileCategory::Episode => videos.push(file.clone()),
                        FileCategory::Sample => samples.push(file.clone()),
                        FileCategory::Trailer | FileCategory::Extra => extras.push(file.clone()),
                        _ => {}
                    }
                }
                MediaType::Subtitle => {
                    file.category = FileCategory::Subtitle;
                    let sub = parse_external_subtitle(file.file_index, &file.path, &file.extension);
                    subtitles.push(sub);
                }
                MediaType::Image => {
                    file.category = FileCategory::Artwork;
                    let art = classify_artwork(file.file_index, &file.path, file.size);
                    artwork.push(art);
                }
                MediaType::Audio => {
                    file.category = FileCategory::MainFeature;
                    audio_files.push(file.clone());
                }
                MediaType::Unknown => {
                    file.category = FileCategory::Ignored;
                }
            }
        }

        videos.sort_by(|a, b| b.confidence_score.partial_cmp(&a.confidence_score).unwrap_or(std::cmp::Ordering::Equal));

        let primary_video = videos.first().cloned();

        let category = detect_collection_category(&videos, &audio_files);

        let media = TorrentMedia {
            torrent_id,
            category,
            primary_video,
            videos,
            audio_files,
            subtitles,
            artwork,
            extras,
            samples,
            total_size,
            file_count: entries.len(),
        };

        self.cache.insert(media.clone());
        Ok(media)
    }
}

impl Default for MetadataAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

fn detect_collection_category(videos: &[MediaFile], audio_files: &[MediaFile]) -> MediaCategory {
    if videos.is_empty() && !audio_files.is_empty() {
        return MediaCategory::Music;
    }

    let mut ep_count = 0;
    for v in videos {
        let lower = v.path.to_lowercase();
        if lower.contains("s0") || lower.contains("e0") || lower.contains("ep") || lower.contains("1x") || lower.contains("2x") {
            ep_count += 1;
        }
    }

    if ep_count >= 2 {
        MediaCategory::TvShow
    } else if videos.len() == 1 || (videos.len() > 1 && ep_count == 0) {
        MediaCategory::Movie
    } else {
        MediaCategory::Other
    }
}
