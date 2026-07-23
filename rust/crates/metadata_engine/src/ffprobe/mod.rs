//! FFprobe inspector for media metadata extraction.

use std::path::Path;
use std::process::Command;
use serde_json::Value;
use tracing::debug;

use crate::models::{AudioTrack, SubtitleTrack, VideoStreamInfo};

/// Inspected media info returned from ffprobe execution.
#[derive(Debug, Clone, Default)]
pub struct FfprobeResult {
    pub video_info: Option<VideoStreamInfo>,
    pub audio_tracks: Vec<AudioTrack>,
    pub subtitle_tracks: Vec<SubtitleTrack>,
}

/// Inspect a local file using `ffprobe` binary if available.
///
/// Returns `Ok(None)` if `ffprobe` is not found on PATH or if the file doesn't exist yet.
pub fn inspect_file(file_path: &Path) -> Result<Option<FfprobeResult>, String> {
    if !file_path.exists() {
        return Ok(None);
    }

    let output = match Command::new("ffprobe")
        .args([
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            file_path.to_str().unwrap_or(""),
        ])
        .output()
    {
        Ok(out) => out,
        Err(e) => {
            debug!("ffprobe not available or failed to execute: {}", e);
            return Ok(None);
        }
    };

    if !output.status.success() {
        return Ok(None);
    }

    let json_str = String::from_utf8_lossy(&output.stdout);
    let v: Value = serde_json::from_str(&json_str).map_err(|e| e.to_string())?;

    let mut res = FfprobeResult::default();

    if let Some(streams) = v.get("streams").and_then(|s| s.as_array()) {
        let mut audio_idx = 0u32;
        let mut sub_idx = 0u32;

        for stream in streams {
            let codec_type = stream.get("codec_type").and_then(|c| c.as_str()).unwrap_or("");
            let codec_name = stream.get("codec_name").and_then(|c| c.as_str()).unwrap_or("unknown");

            match codec_type {
                "video" => {
                    let width = stream.get("width").and_then(|w| w.as_u64()).unwrap_or(0) as u32;
                    let height = stream.get("height").and_then(|h| h.as_u64()).unwrap_or(0) as u32;
                    let duration = stream
                        .get("duration")
                        .and_then(|d| d.as_str())
                        .and_then(|s| s.parse::<f64>().ok())
                        .unwrap_or(0.0);
                    let bitrate = stream
                        .get("bit_rate")
                        .and_then(|b| b.as_str())
                        .and_then(|s| s.parse::<u64>().ok())
                        .unwrap_or(0);

                    res.video_info = Some(VideoStreamInfo {
                        width,
                        height,
                        codec: codec_name.to_string(),
                        frame_rate: 23.976,
                        duration_seconds: duration,
                        bitrate,
                    });
                }
                "audio" => {
                    let channels = stream.get("channels").and_then(|c| c.as_u64()).unwrap_or(2) as u32;
                    let lang = stream
                        .get("tags")
                        .and_then(|t| t.get("language"))
                        .and_then(|l| l.as_str())
                        .unwrap_or("eng")
                        .to_string();
                    let title = stream
                        .get("tags")
                        .and_then(|t| t.get("title"))
                        .and_then(|l| l.as_str())
                        .unwrap_or("")
                        .to_string();

                    res.audio_tracks.push(AudioTrack {
                        index: audio_idx,
                        language: lang,
                        title,
                        codec: codec_name.to_string(),
                        channels,
                        bitrate: 0,
                    });
                    audio_idx += 1;
                }
                "subtitle" => {
                    let lang = stream
                        .get("tags")
                        .and_then(|t| t.get("language"))
                        .and_then(|l| l.as_str())
                        .unwrap_or("eng")
                        .to_string();
                    let title = stream
                        .get("tags")
                        .and_then(|t| t.get("title"))
                        .and_then(|l| l.as_str())
                        .unwrap_or("")
                        .to_string();

                    res.subtitle_tracks.push(SubtitleTrack {
                        index: sub_idx,
                        language: lang,
                        title,
                        format: codec_name.to_uppercase(),
                        is_external: false,
                        is_forced: false,
                        is_default: sub_idx == 0,
                        file_path: None,
                    });
                    sub_idx += 1;
                }
                _ => {}
            }
        }
    }

    Ok(Some(res))
}
