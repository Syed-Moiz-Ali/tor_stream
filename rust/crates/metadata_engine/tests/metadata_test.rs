//! Comprehensive unit & integration tests for metadata_engine.

use metadata_engine::{
    bridge as engine,
    models::{FileCategory, MediaCategory},
    parser::RawFileEntry,
};

#[test]
fn test_movie_torrent_detection() {
    let entries = vec![
        RawFileEntry { index: 0, path: "Inception (2010)/Inception.2010.1080p.mkv".into(), size: 4_500_000_000 },
        RawFileEntry { index: 1, path: "Inception (2010)/Sample/sample.mkv".into(), size: 25_000_000 },
        RawFileEntry { index: 2, path: "Inception (2010)/poster.jpg".into(), size: 250_000 },
        RawFileEntry { index: 3, path: "Inception (2010)/English.srt".into(), size: 85_000 },
        RawFileEntry { index: 4, path: "Inception (2010)/readme.txt".into(), size: 1_200 },
    ];

    let media = engine::scan_torrent(1, entries, None).unwrap();

    assert_eq!(media.category, MediaCategory::Movie);
    assert_eq!(media.file_count, 5);
    assert!(media.primary_video.is_some());

    let primary = media.primary_video.unwrap();
    assert_eq!(primary.file_name, "Inception.2010.1080p.mkv");
    assert_eq!(primary.category, FileCategory::MainFeature);
    assert!(primary.confidence_score > 0.6);

    assert_eq!(media.subtitles.len(), 1);
    assert_eq!(media.subtitles[0].language, "eng");
    assert_eq!(media.artwork.len(), 1);
    assert_eq!(media.samples.len(), 1);
}

#[test]
fn test_tv_show_torrent_detection() {
    let entries = vec![
        RawFileEntry { index: 0, path: "Breaking Bad S01/Breaking.Bad.S01E01.720p.mkv".into(), size: 1_200_000_000 },
        RawFileEntry { index: 1, path: "Breaking Bad S01/Breaking.Bad.S01E02.720p.mkv".into(), size: 1_180_000_000 },
        RawFileEntry { index: 2, path: "Breaking Bad S01/Breaking.Bad.S01E03.720p.mkv".into(), size: 1_250_000_000 },
        RawFileEntry { index: 3, path: "Breaking Bad S01/Subs/S01E01.srt".into(), size: 45_000 },
    ];

    let media = engine::scan_torrent(2, entries, None).unwrap();

    assert_eq!(media.category, MediaCategory::TvShow);
    assert_eq!(media.videos.len(), 3);
}

#[test]
fn test_anime_torrent_detection() {
    let entries = vec![
        RawFileEntry { index: 0, path: "[SubsPlease] Frieren - 01 (1080p).mkv".into(), size: 1_400_000_000 },
        RawFileEntry { index: 1, path: "[SubsPlease] Frieren - 02 (1080p).mkv".into(), size: 1_380_000_000 },
    ];

    let media = engine::scan_torrent(3, entries, None).unwrap();
    assert_eq!(media.videos.len(), 2);
}

#[test]
fn test_music_album_detection() {
    let entries = vec![
        RawFileEntry { index: 0, path: "Daft Punk - Discovery/01 One More Time.flac".into(), size: 45_000_000 },
        RawFileEntry { index: 1, path: "Daft Punk - Discovery/02 Aerodynamic.flac".into(), size: 38_000_000 },
        RawFileEntry { index: 2, path: "Daft Punk - Discovery/cover.jpg".into(), size: 120_000 },
    ];

    let media = engine::scan_torrent(4, entries, None).unwrap();

    assert_eq!(media.category, MediaCategory::Music);
    assert_eq!(media.audio_files.len(), 2);
    assert_eq!(media.artwork.len(), 1);
}

#[test]
fn test_empty_torrent_error() {
    let result = engine::scan_torrent(5, vec![], None);
    assert!(result.is_err());
}

#[test]
fn test_nested_folders_and_duplicates() {
    let entries = vec![
        RawFileEntry { index: 0, path: "Movie.1080p/Movie.1080p.mkv".into(), size: 8_000_000_000 },
        RawFileEntry { index: 1, path: "Movie.1080p/Extras/BehindTheScenes.mp4".into(), size: 400_000_000 },
    ];

    let media = engine::scan_torrent(6, entries, None).unwrap();
    assert_eq!(media.videos[0].category, FileCategory::MainFeature);
    assert_eq!(media.extras.len(), 1);
}
