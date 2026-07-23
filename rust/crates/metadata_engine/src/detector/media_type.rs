//! Extensions and classification rules for media files.

use crate::models::MediaType;

pub const VIDEO_EXTENSIONS: &[&str] = &[
    "mkv", "mp4", "avi", "mov", "webm", "mpeg", "mpg", "ts", "m2ts",
];

pub const AUDIO_EXTENSIONS: &[&str] = &[
    "aac", "ac3", "dts", "flac", "mp3", "opus", "m4a", "ogg", "wav",
];

pub const SUBTITLE_EXTENSIONS: &[&str] = &[
    "srt", "ass", "ssa", "vtt", "pgs", "sup", "idx", "sub",
];

pub const ARTWORK_EXTENSIONS: &[&str] = &[
    "jpg", "jpeg", "png", "webp", "bmp",
];

pub const IGNORED_EXTENSIONS: &[&str] = &[
    "txt", "nfo", "url", "exe", "bat", "cmd", "sh", "rar", "zip", "sfv", "md5",
];

/// Determine the basic [`MediaType`] from file extension.
pub fn detect_media_type(ext: &str) -> MediaType {
    let lower = ext.to_lowercase();
    if VIDEO_EXTENSIONS.contains(&lower.as_str()) {
        MediaType::Video
    } else if AUDIO_EXTENSIONS.contains(&lower.as_str()) {
        MediaType::Audio
    } else if SUBTITLE_EXTENSIONS.contains(&lower.as_str()) {
        MediaType::Subtitle
    } else if ARTWORK_EXTENSIONS.contains(&lower.as_str()) {
        MediaType::Image
    } else {
        MediaType::Unknown
    }
}
