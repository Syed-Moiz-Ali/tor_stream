//! Unit and integration tests for reliability_engine.

use tempfile::tempdir;
use reliability_engine::{
    bridge as engine,
    backup::BackupManager,
    models::SessionSnapshot,
    persistence::SessionStore,
    recovery::RecoveryManager,
    resume::should_auto_resume,
    verification::StorageVerifier,
};

#[test]
fn test_session_persistence_and_recovery() {
    let dir = tempdir().unwrap();
    let db_path = dir.path().join("test_session.db");

    let manager = RecoveryManager::new(&db_path).unwrap();

    let snapshot = SessionSnapshot {
        torrent_id: 42,
        info_hash: "0123456789abcdef0123456789abcdef01234567".into(),
        magnet_uri: Some("magnet:?xt=urn:btih:0123456789abcdef0123456789abcdef01234567".into()),
        file_index: 0,
        playback_position_bytes: 15_000_000,
        total_bytes: 100_000_000,
        selected_audio_track: 1,
        selected_subtitle_track: 0,
        playback_speed: 1.0,
        is_playing: true,
        last_active_timestamp_ms: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis() as i64,
    };

    manager.save_session_state(&snapshot).unwrap();

    let restored = manager.restore_latest_session().unwrap();
    assert!(restored.is_some());

    let r = restored.unwrap();
    assert_eq!(r.torrent_id, 42);
    assert_eq!(r.playback_position_bytes, 15_000_000);
    assert!(r.is_playing);
}

#[test]
fn test_auto_resume_evaluator() {
    let now_ms = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis() as i64;

    let fresh_snapshot = SessionSnapshot {
        torrent_id: 1,
        info_hash: "hash".into(),
        magnet_uri: None,
        file_index: 0,
        playback_position_bytes: 0,
        total_bytes: 100,
        selected_audio_track: 0,
        selected_subtitle_track: 0,
        playback_speed: 1.0,
        is_playing: true,
        last_active_timestamp_ms: now_ms - 1000, // 1 second ago
    };

    assert!(should_auto_resume(&fresh_snapshot, 3600_000));
}

#[test]
fn test_storage_verification_and_backup() {
    let dir = tempdir().unwrap();
    let db_path = dir.path().join("app.db");
    let backup_dir = dir.path().join("backups");

    let store = SessionStore::open(&db_path).unwrap();
    assert!(db_path.exists());

    let report = StorageVerifier::verify_and_repair(&db_path, dir.path()).unwrap();
    assert!(report.database_vacuumed);

    let backup_dest = BackupManager::create_backup(&db_path, &backup_dir).unwrap();
    assert!(backup_dest.exists());
}

#[test]
fn test_bridge_api_functions() {
    let health = engine::health_status().unwrap();
    assert!(health.is_healthy);

    let report = engine::verify_storage().unwrap();
    assert!(report.free_space_bytes > 0);
}
