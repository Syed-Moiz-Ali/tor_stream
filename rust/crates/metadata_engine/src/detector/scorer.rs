//! Weighted scoring algorithm for detecting main features vs samples/extras.

use crate::models::{FileCategory, VideoStreamInfo};

/// Calculate confidence score (0.0 to 1.0) for a video file being the main feature,
/// and determine its [`FileCategory`].
pub fn score_video_file(
    path: &str,
    size: u64,
    max_video_size: u64,
    ext: &str,
    video_info: Option<&VideoStreamInfo>,
) -> (FileCategory, f32) {
    let lower_path = path.to_lowercase();
    let file_name = lower_path.split(['/', '\\']).last().unwrap_or(&lower_path);

    // 1. Hard sample / extra checks
    if file_name.contains("sample") || file_name.contains("trailer") || lower_path.contains("/sample/") || lower_path.contains("\\sample\\") {
        if file_name.contains("sample") {
            return (FileCategory::Sample, 0.0);
        } else {
            return (FileCategory::Trailer, 0.1);
        }
    }

    if lower_path.contains("extra") || lower_path.contains("featurette") || lower_path.contains("bonus") || lower_path.contains("behind the scenes") {
        return (FileCategory::Extra, 0.2);
    }

    // Small file check: videos under 100MB when a >1GB video exists in torrent are samples/extras
    if size < 100 * 1024 * 1024 && max_video_size > 1024 * 1024 * 1024 {
        return (FileCategory::Sample, 0.05);
    }

    // 2. Extension scoring (max 0.20)
    let ext_score = match ext.to_lowercase().as_str() {
        "mkv" => 0.20,
        "mp4" => 0.19,
        "m2ts" | "ts" => 0.15,
        "mov" => 0.14,
        "webm" => 0.13,
        "avi" => 0.10,
        _ => 0.05,
    };

    // 3. Size scoring relative to largest file (max 0.50)
    let size_ratio = if max_video_size > 0 {
        (size as f64 / max_video_size as f64) as f32
    } else {
        1.0
    };
    let size_score = size_ratio * 0.50;

    // 4. Folder depth & path penalty (max 0.15)
    let depth = path.split(['/', '\\']).count();
    let depth_score = if depth <= 2 { 0.15 } else if depth == 3 { 0.10 } else { 0.05 };

    // 5. Video duration / resolution bonus (max 0.15)
    let mut metadata_bonus = 0.0;
    if let Some(info) = video_info {
        if info.duration_seconds > 1800.0 { // > 30 mins
            metadata_bonus += 0.10;
        } else if info.duration_seconds > 300.0 {
            metadata_bonus += 0.05;
        }

        if info.height >= 1080 {
            metadata_bonus += 0.05;
        } else if info.height >= 720 {
            metadata_bonus += 0.03;
        }
    } else {
        // Default bonus if no ffprobe info
        metadata_bonus = 0.08;
    }

    let final_score = (ext_score + size_score + depth_score + metadata_bonus).clamp(0.0, 1.0);

    let category = if final_score > 0.4 {
        FileCategory::MainFeature
    } else {
        FileCategory::Extra
    };

    (category, final_score)
}
