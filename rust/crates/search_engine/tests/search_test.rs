//! Unit and integration tests for search_engine.

use search_engine::{
    bridge as engine,
    collection_engine::CollectionEngine,
    duplicate::DuplicateDetector,
    engine::CoreSearchEngine,
    filter_engine::FilterEngine,
    index_engine::IndexEngine,
    metadata_index::extract_search_tags,
    models::{SearchFilters, SearchResultItem, SortBy, SortDirection, SortOptions},
    persistence::SearchStore,
};

#[test]
fn test_search_engine_fts_query_performance() {
    let dir = tempfile::tempdir().unwrap();
    let db_path = dir.path().join("search_test.db");
    let store = SearchStore::open(&db_path).unwrap();

    let indexer = IndexEngine::new(store.clone());

    // Generate 1000 items to test index query speed
    let mut items = Vec::with_capacity(1000);
    for i in 1..=1000 {
        items.push(SearchResultItem {
            torrent_id: i,
            title: format!("Movie Title Matrix Part {}", i),
            category: if i % 2 == 0 { "Movie".into() } else { "TvShow".into() },
            file_name: format!("matrix_part_{}.mkv", i),
            resolution: if i % 4 == 0 { "3840x2160".into() } else { "1920x1080".into() },
            codec: "HEVC".into(),
            total_bytes: 10_000_000_000,
            progress: 0.5,
            relevance_score: 1.0,
        });
    }

    indexer.index_items(&items).unwrap();

    let searcher = CoreSearchEngine::new(store);

    let start = std::time::Instant::now();
    let results = searcher.execute_search("Matrix Part 50").unwrap();
    let elapsed = start.elapsed();

    assert!(!results.is_empty());
    assert!(elapsed.as_millis() < 50, "Search query took {} ms (expected < 50ms)", elapsed.as_millis());
}

#[test]
fn test_filtering_and_sorting() {
    let items = vec![
        SearchResultItem {
            torrent_id: 1,
            title: "Zebra Movie".into(),
            category: "Movie".into(),
            file_name: "zebra.mkv".into(),
            resolution: "1920x1080".into(),
            codec: "AVC".into(),
            total_bytes: 2_000_000,
            progress: 1.0,
            relevance_score: 1.0,
        },
        SearchResultItem {
            torrent_id: 2,
            title: "Alpha Movie 4K".into(),
            category: "Movie".into(),
            file_name: "alpha.mkv".into(),
            resolution: "3840x2160".into(),
            codec: "HEVC".into(),
            total_bytes: 10_000_000,
            progress: 0.1,
            relevance_score: 1.0,
        },
    ];

    let filters = SearchFilters {
        resolution: Some("3840x2160".into()),
        ..Default::default()
    };

    let filtered = FilterEngine::filter_items(items.clone(), &filters);
    assert_eq!(filtered.len(), 1);
    assert_eq!(filtered[0].torrent_id, 2);

    let sorted = FilterEngine::sort_items(items, &SortOptions {
        sort_by: SortBy::Title,
        direction: SortDirection::Ascending,
    });
    assert_eq!(sorted[0].title, "Alpha Movie 4K");
}

#[test]
fn test_duplicate_detector() {
    let items = vec![
        SearchResultItem {
            torrent_id: 1,
            title: "Dune 2021 1080p".into(),
            category: "Movie".into(),
            file_name: "dune.mkv".into(),
            resolution: "1080p".into(),
            codec: "AVC".into(),
            total_bytes: 5_000_000,
            progress: 1.0,
            relevance_score: 1.0,
        },
        SearchResultItem {
            torrent_id: 2,
            title: "Dune 2021 1080p".into(),
            category: "Movie".into(),
            file_name: "dune_4k.mkv".into(),
            resolution: "4K".into(),
            codec: "HEVC".into(),
            total_bytes: 20_000_000,
            progress: 0.5,
            relevance_score: 1.0,
        },
    ];

    let dupes = DuplicateDetector::detect_duplicates(&items);
    assert_eq!(dupes.len(), 1);
    assert_eq!(dupes[0].torrent_ids.len(), 2);
}

#[test]
fn test_collection_engine_lifecycle() {
    let dir = tempfile::tempdir().unwrap();
    let db_path = dir.path().join("collection_test.db");
    let store = SearchStore::open(&db_path).unwrap();

    let collection_mgr = CollectionEngine::new(store);
    let col_id = collection_mgr.create_collection("Watch Later", "Movies to watch this weekend").unwrap();

    collection_mgr.add_item(col_id, 101).unwrap();
    collection_mgr.remove_item(col_id, 101).unwrap();
    collection_mgr.delete_collection(col_id).unwrap();
}

#[test]
fn test_bridge_api_functions() {
    let col_id = engine::create_collection("Sci-Fi Classics".into(), "Top sci-fi movies".into()).unwrap();
    engine::add_to_collection(col_id, 999).unwrap();
    engine::remove_from_collection(col_id, 999).unwrap();
    engine::delete_collection(col_id).unwrap();
}
