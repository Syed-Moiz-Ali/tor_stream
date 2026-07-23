//! Resume data persistence tests.
//!
//! Tests that SQLite records are created, updated, and deleted correctly.
//! No network access required — all tests use the in-process SQLite store.

use std::path::PathBuf;
use torrent_engine::{
    EngineConfig,
    resume::store::ResumeStore,
    models::TorrentStatus,
};

fn open_store(dir: &tempfile::TempDir) -> ResumeStore {
    let db_path = dir.path().join("test.db");
    ResumeStore::open(&db_path).expect("Failed to open test database")
}

// ── Schema + basic CRUD ───────────────────────────────────────────────────────

#[tokio::test]
async fn test_store_opens_and_migrates() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);
    // If open() returned Ok, the schema migration succeeded.
    let torrents = store.load_all_torrents().await.unwrap();
    assert!(torrents.is_empty(), "Fresh store should have no records");
}

#[tokio::test]
async fn test_upsert_and_load_torrent() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    store
        .upsert_torrent(
            42,
            "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
            Some("Ubuntu 22.04"),
            "/downloads",
            1_700_000_000_000,
        )
        .await
        .unwrap();

    let all = store.load_all_torrents().await.unwrap();
    assert_eq!(all.len(), 1, "Expected 1 torrent after insert");

    let t = &all[0];
    assert_eq!(t.id, 42);
    assert_eq!(t.info_hash, "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef");
    assert_eq!(t.name, Some("Ubuntu 22.04".into()));
    assert_eq!(t.save_path, "/downloads");
    assert_eq!(t.added_at_ms, 1_700_000_000_000);
}

#[tokio::test]
async fn test_upsert_is_idempotent() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    // Insert twice with the same ID — should not duplicate.
    for _ in 0..2 {
        store
            .upsert_torrent(1, "aabbccdd".repeat(5).as_str(), Some("Test"), "/dl", 0)
            .await
            .unwrap();
    }

    let all = store.load_all_torrents().await.unwrap();
    assert_eq!(all.len(), 1, "Duplicate upsert created extra rows");
}

#[tokio::test]
async fn test_set_status_updates_record() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    store
        .upsert_torrent(7, &"aa".repeat(20), None, "/dl", 0)
        .await
        .unwrap();

    store.set_status(7, TorrentStatus::Paused).await.unwrap();

    let all = store.load_all_torrents().await.unwrap();
    assert_eq!(all[0].status, TorrentStatus::Paused);
}

#[tokio::test]
async fn test_delete_torrent_removes_record() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    store
        .upsert_torrent(99, &"bb".repeat(20), None, "/dl", 0)
        .await
        .unwrap();

    store.delete_torrent(99).await.unwrap();

    let all = store.load_all_torrents().await.unwrap();
    assert!(all.is_empty(), "Record should have been deleted");
}

// ── Resume data BLOB ─────────────────────────────────────────────────────────

#[tokio::test]
async fn test_save_and_load_resume_data() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    // Must have a parent torrent record first (FK constraint).
    store
        .upsert_torrent(5, &"cc".repeat(20), None, "/dl", 0)
        .await
        .unwrap();

    let blob: Vec<u8> = b"resume-blob-payload".to_vec();
    store.save_resume_data(5, blob.clone()).await.unwrap();

    let loaded = store.load_resume_data(5).await.unwrap();
    assert_eq!(loaded, Some(blob), "Resume data round-trip failed");
}

#[tokio::test]
async fn test_load_resume_data_returns_none_for_unknown_id() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    let result = store.load_resume_data(9999).await.unwrap();
    assert!(result.is_none(), "Expected None for unknown torrent id");
}

#[tokio::test]
async fn test_resume_data_cascades_on_delete() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    store
        .upsert_torrent(3, &"dd".repeat(20), None, "/dl", 0)
        .await
        .unwrap();
    store.save_resume_data(3, b"data".to_vec()).await.unwrap();

    // Deleting the parent row should cascade-delete the resume row.
    store.delete_torrent(3).await.unwrap();

    let result = store.load_resume_data(3).await.unwrap();
    assert!(result.is_none(), "Resume data should cascade-delete");
}

// ── Multiple torrents ─────────────────────────────────────────────────────────

#[tokio::test]
async fn test_load_all_torrents_returns_in_insertion_order() {
    let dir   = tempfile::tempdir().unwrap();
    let store = open_store(&dir);

    for i in 0u64..5 {
        store
            .upsert_torrent(
                i,
                &format!("{:040}", i),
                Some(&format!("Torrent {}", i)),
                "/dl",
                i as i64 * 1000,
            )
            .await
            .unwrap();
    }

    let all = store.load_all_torrents().await.unwrap();
    assert_eq!(all.len(), 5);
    // Ordered by added_at_ms ASC.
    for (idx, t) in all.iter().enumerate() {
        assert_eq!(t.id, idx as u64, "Unexpected order at index {}", idx);
    }
}
