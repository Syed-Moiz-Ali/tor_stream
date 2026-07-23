//! Media models for Phase 3.

use serde::{Deserialize, Serialize};

/// High-level collection category detected for a torrent.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MediaCategory {
    Movie,
    TvShow,
    Anime,
    Music,
    Other,
}

/// Category of an individual file within the torrent.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum FileCategory {
    MainFeature,
    Episode,
    Subtitle,
    Artwork,
    Trailer,
    Extra,
    Sample,
    Ignored,
}

/// Format type of media.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MediaType {
    Video,
    Audio,
    Subtitle,
    Image,
    Unknown,
}

/// Video stream metadata extracted via detector or ffprobe.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct VideoStreamInfo {
    pub width: u32,
    pub height: u32,
    pub codec: String,
    pub frame_rate: f32,
    pub duration_seconds: f64,
    pub bitrate: u64,
}

/// Audio track details.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AudioTrack {
    pub index: u32,
    pub language: String,
    pub title: String,
    pub codec: String,
    pub channels: u32,
    pub bitrate: u64,
}

/// Subtitle track details (internal stream or external file).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SubtitleTrack {
    pub index: u32,
    pub language: String,
    pub title: String,
    pub format: String,
    pub is_external: bool,
    pub is_forced: bool,
    pub is_default: bool,
    pub file_path: Option<String>,
}

/// Artwork file details.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Artwork {
    pub file_index: u32,
    pub path: String,
    pub size: u64,
    pub artwork_type: ArtworkType,
}

/// Type of artwork image.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtworkType {
    Poster,
    Backdrop,
    Cover,
    Thumbnail,
    Unknown,
}

/// Information about a single file in a torrent.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaFile {
    pub file_index: u32,
    pub path: String,
    pub file_name: String,
    pub extension: String,
    pub size: u64,
    pub media_type: MediaType,
    pub category: FileCategory,
    pub confidence_score: f32,
    pub video_info: Option<VideoStreamInfo>,
    pub audio_tracks: Vec<AudioTrack>,
    pub subtitle_tracks: Vec<SubtitleTrack>,
}

/// Complete media model for a torrent.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TorrentMedia {
    pub torrent_id: u64,
    pub category: MediaCategory,
    pub primary_video: Option<MediaFile>,
    pub videos: Vec<MediaFile>,
    pub audio_files: Vec<MediaFile>,
    pub subtitles: Vec<SubtitleTrack>,
    pub artwork: Vec<Artwork>,
    pub extras: Vec<MediaFile>,
    pub samples: Vec<MediaFile>,
    pub total_size: u64,
    pub file_count: usize,
}

/// Aggregated media collection view.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaCollection {
    pub torrents: Vec<TorrentMedia>,
    pub total_media_files: usize,
}
