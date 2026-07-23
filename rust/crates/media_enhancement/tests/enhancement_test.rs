//! Unit and integration tests for media_enhancement.

use media_enhancement::{
    audio_engine::AudioEngine,
    bridge as engine,
    chapter_engine::ChapterEngine,
    media_info::MediaInfoExtractor,
    models::{SubtitleConfig, SubtitleFormat},
    playback_engine::PlaybackEngine,
    subtitle_engine::SubtitleEngine,
    thumbnail_engine::ThumbnailEngine,
};

#[test]
fn test_subtitle_format_detection_and_styling() {
    let fmt_ass = SubtitleEngine::parse_format_by_extension("ass");
    let fmt_srt = SubtitleEngine::parse_format_by_extension("srt");
    let fmt_vtt = SubtitleEngine::parse_format_by_extension("vtt");

    assert_eq!(fmt_ass, SubtitleFormat::Ass);
    assert_eq!(fmt_srt, SubtitleFormat::Srt);
    assert_eq!(fmt_vtt, SubtitleFormat::Vtt);

    let engine = SubtitleEngine::new();
    let mut config = SubtitleConfig::default();
    config.delay_ms = 500;
    engine.set_config(config);

    assert_eq!(engine.get_config().delay_ms, 500);
    assert_eq!(engine.adjust_delay(-200), 300);
}

#[test]
fn test_audio_engine_track_selection() {
    let audio = AudioEngine::new();

    audio.select_track(2);
    audio.set_audio_delay(-150);

    assert_eq!(audio.get_active_track(), 2);
    assert_eq!(audio.get_audio_delay(), -150);
}

#[test]
fn test_chapter_engine_parsing_and_jump() {
    let chapters = ChapterEngine::parse_chapters(3600.0); // 1 hour
    assert!(chapters.len() >= 5);

    let offset = ChapterEngine::get_chapter_offset(&chapters, 2);
    assert!(offset.is_some());
}

#[test]
fn test_thumbnail_engine_generation() {
    let dir = tempfile::tempdir().unwrap();
    let thumbs = ThumbnailEngine::generate_timeline_thumbnails(600.0, 60, &dir.path().to_path_buf());
    assert_eq!(thumbs.len(), 10);
}

#[test]
fn test_media_info_extractor() {
    let info = MediaInfoExtractor::inspect_media("MKV", 7200.0, 3840, 2160, 45_000_000, 23.976, true);
    assert_eq!(info.container, "MKV");
    assert_eq!(info.video_codec, "HEVC (H.265)");
    assert!(info.is_hdr);
}

#[test]
fn test_playback_engine_speed_clamping() {
    let pb = PlaybackEngine::new();
    assert_eq!(pb.set_speed(1.5), 1.5);
    assert_eq!(pb.set_speed(5.0), 3.0); // clamped to 3.0 max
    assert_eq!(pb.set_speed(0.1), 0.25); // clamped to 0.25 min
}

#[test]
fn test_bridge_api_functions() {
    engine::load_subtitles(SubtitleConfig::default()).unwrap();
    let new_delay = engine::change_subtitle(150).unwrap();
    assert_eq!(new_delay, 150);

    let speed = engine::set_playback_speed(1.25).unwrap();
    assert_eq!(speed, 1.25);

    let chapters = engine::get_chapters(1800.0).unwrap();
    assert!(!chapters.is_empty());
}
