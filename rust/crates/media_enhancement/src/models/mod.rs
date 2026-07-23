//! Domain models for media enhancement.

use serde::{Deserialize, Serialize};

/// Supported Subtitle Format.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SubtitleFormat {
    Srt,
    Ass,
    Ssa,
    Vtt,
    Sub,
    Idx,
    Pgs,
    Sup,
}

/// Subtitle visual styling and configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubtitleConfig {
    pub delay_ms: i64,
    pub font_size_pt: u32,
    pub color_hex: String,
    pub background_color_hex: String,
    pub outline_color_hex: String,
    pub shadow_enabled: bool,
    pub encoding: String,
}

impl Default for SubtitleConfig {
    fn default() -> Self {
        Self {
            delay_ms: 0,
            font_size_pt: 20,
            color_hex: "#FFFFFF".into(),
            background_color_hex: "#00000080".into(),
            outline_color_hex: "#000000".into(),
            shadow_enabled: true,
            encoding: "UTF-8".into(),
        }
    }
}

/// Extended Audio Track metadata.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnhancedAudioTrack {
    pub index: u32,
    pub language: String,
    pub title: String,
    pub codec: String,
    pub channels: u32,
    pub channel_layout: String, // e.g. "5.1 Surround", "7.1", "Stereo"
    pub bitrate_bps: u64,
    pub delay_ms: i64,
}

/// Media Chapter representation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaChapter {
    pub index: usize,
    pub title: String,
    pub start_ms: u64,
    pub end_ms: u64,
}

/// Generated Media Thumbnail representation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaThumbnail {
    pub timestamp_ms: u64,
    pub image_path: String,
    pub width: u32,
    pub height: u32,
}

/// Full Technical Media Information.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FullMediaInfo {
    pub container: String,
    pub duration_seconds: f64,
    pub video_codec: String,
    pub resolution_width: u32,
    pub resolution_height: u32,
    pub bitrate_bps: u64,
    pub frame_rate: f32,
    pub is_hdr: bool,
    pub color_space: String,
    pub aspect_ratio: String,
    pub total_audio_tracks: usize,
    pub total_subtitle_tracks: usize,
    pub total_chapters: usize,
}
