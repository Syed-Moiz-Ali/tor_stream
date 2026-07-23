//! Unit and integration tests for download_manager.

use tempfile::tempdir;
use download_manager::{
    bridge as engine,
    continue_watching::ContinueWatchingManager,
    library::MediaLibrary,
    models::{
        ContinueWatchingItem, DownloadState, DownloadTask, LibraryItem, MediaCategory,
        QueuePriority,
    },
    persistence::LibraryStore,
    queue::DownloadQueue,
};

#[test]
fn test_download_queue_scheduling_and_priority() {
    let dir = tempdir().unwrap();
    let db_path = dir.path().join("library_test.db");
    let store = LibraryStore::open(&db_path).unwrap();

    let queue = DownloadQueue::new(store, 2).unwrap();

    let task1 = DownloadTask {
        id: 1,
        torrent_id: 101,
        title: "Movie A".into(),
        save_path: "/downloads".into(),
        total_bytes: 1_000_000,
        downloaded_bytes: 0,
        progress: 0.0,
        download_speed_bps: 0,
        priority: QueuePriority::Normal,
        state: DownloadState::Queued,
        added_at_ms: 100,
    };

    let task2 = DownloadTask {
        id: 2,
        torrent_id: 102,
        title: "Movie B (High Priority)".into(),
        save_path: "/downloads".into(),
        total_bytes: 2_000_000,
        downloaded_bytes: 0,
        progress: 0.0,
        download_speed_bps: 0,
        priority: QueuePriority::High,
        state: DownloadState::Queued,
        added_at_ms: 200,
    };

    queue.enqueue_task(task1).unwrap();
    queue.enqueue_task(task2).unwrap();

    let all = queue.get_all();
    assert_eq!(all.len(), 2);
    // Task 2 should be promoted first because it has High priority
    assert_eq!(all[0].id, 2);
    assert_eq!(all[0].state, DownloadState::Downloading);
}

#[test]
fn test_media_library_search_and_favorites() {
    let dir = tempdir().unwrap();
    let db_path = dir.path().join("library_test2.db");
    let store = LibraryStore::open(&db_path).unwrap();

    let library = MediaLibrary::new(store);

    let item1 = LibraryItem {
        id: 1,
        torrent_id: 201,
        title: "Inception 4K Remux".into(),
        category: MediaCategory::Movie,
        primary_file_index: 0,
        total_bytes: 50_000_000_000,
        artwork_path: None,
        is_favorite: false,
        date_added_ms: 1000,
    };

    let item2 = LibraryItem {
        id: 2,
        torrent_id: 202,
        title: "Cyberpunk Edgerunners S01".into(),
        category: MediaCategory::Anime,
        primary_file_index: 0,
        total_bytes: 12_000_000_000,
        artwork_path: None,
        is_favorite: false,
        date_added_ms: 2000,
    };

    library.add_item(&item1).unwrap();
    library.add_item(&item2).unwrap();

    let results = library.search("inception").unwrap();
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].torrent_id, 201);

    library.toggle_favorite(201).unwrap();
    let all = library.get_all().unwrap();
    let fav = all.into_iter().find(|i| i.torrent_id == 201).unwrap();
    assert!(fav.is_favorite);
}

#[test]
fn test_continue_watching_progress() {
    let dir = tempdir().unwrap();
    let db_path = dir.path().join("cw_test.db");
    let store = LibraryStore::open(&db_path).unwrap();

    let cw = ContinueWatchingManager::new(store);

    let cw_item = ContinueWatchingItem {
        id: 1,
        torrent_id: 301,
        file_index: 0,
        title: "Dune Part Two".into(),
        artwork_path: None,
        position_ms: 45 * 60 * 1000,
        duration_ms: 165 * 60 * 1000,
        progress_pct: 0.27,
        last_played_ms: 5000,
    };

    cw.update_progress(cw_item).unwrap();
    let items = cw.get_items().unwrap();
    assert_eq!(items.len(), 1);
    assert_eq!(items[0].position_ms, 45 * 60 * 1000);
}

#[test]
fn test_bridge_api_functions() {
    let download_id = engine::start_download(501, "Test Movie".into(), "/downloads".into(), 1000).unwrap();
    assert_eq!(download_id, 501);

    engine::pause_download(501).unwrap();
    engine::resume_download(501).unwrap();
    engine::set_bandwidth_limit(10_000_000, 2_000_000, true).unwrap();
}
