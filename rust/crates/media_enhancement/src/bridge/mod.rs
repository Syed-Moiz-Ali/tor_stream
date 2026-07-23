//! Public Rust API for media_enhancement.

use std::sync::OnceLock;

use crate::audio_engine::AudioEngine;
use crate::chapter_engine::ChapterEngine;
use crate::models::{
    MediaChapter, MediaThumbnail, SubtitleConfig,
};
use crate::playback_engine::PlaybackEngine;
use crate::subtitle_engine::SubtitleEngine;
use crate::thumbnail_engine::ThumbnailEngine;

static SUBTITLE: OnceLock<SubtitleEngine> = OnceLock::new();
static AUDIO: OnceLock<AudioEngine> = OnceLock::new();
static PLAYBACK: OnceLock<PlaybackEngine> = OnceLock::new();

fn get_subtitle_engine() -> &'static SubtitleEngine {
    SUBTITLE.get_or_init(SubtitleEngine::new)
}

fn get_audio_engine() -> &'static AudioEngine {
    AUDIO.get_or_init(AudioEngine::new)
}

fn get_playback_engine() -> &'static PlaybackEngine {
    PLAYBACK.get_or_init(PlaybackEngine::new)
}

/// Load and configure subtitle engine.
pub fn load_subtitles(config: SubtitleConfig) -> anyhow::Result<()> {
    get_subtitle_engine().set_config(config);
    Ok(())
}

/// Change active subtitle track and adjust delay offset.
pub fn change_subtitle(delay_ms: i64) -> anyhow::Result<i64> {
    Ok(get_subtitle_engine().adjust_delay(delay_ms))
}

/// Change active audio track index.
pub fn change_audio_track(track_index: u32) -> anyhow::Result<()> {
    get_audio_engine().select_track(track_index);
    Ok(())
}

/// Generate media thumbnails.
pub fn generate_thumbnails(duration_seconds: f64, interval_seconds: u32) -> anyhow::Result<Vec<MediaThumbnail>> {
    let cache_dir = std::env::temp_dir().join("tor_stream_thumbs");
    let _ = std::fs::create_dir_all(&cache_dir);
    Ok(ThumbnailEngine::generate_timeline_thumbnails(
        duration_seconds,
        interval_seconds,
        &cache_dir,
    ))
}

/// Retrieve chapters for media duration.
pub fn get_chapters(duration_seconds: f64) -> anyhow::Result<Vec<MediaChapter>> {
    Ok(ChapterEngine::parse_chapters(duration_seconds))
}

/// Set active playback speed multiplier.
pub fn set_playback_speed(speed: f32) -> anyhow::Result<f32> {
    Ok(get_playback_engine().set_speed(speed))
}
