//! Torrent operation tests — add, pause, resume, remove, invalid inputs.

use torrent_engine::{EngineConfig, bridge as engine};

fn test_config(dir: &tempfile::TempDir) -> EngineConfig {
    EngineConfig {
        download_dir:  dir.path().join("downloads"),
        data_dir:      dir.path().join("data"),
        listen_port:   16002,
        dht_enabled:   false,
        lsd_enabled:   false,
        upnp_enabled:  false,
        natpmp_enabled: false,
        ..EngineConfig::default()
    }
}

#[tokio::test]
async fn test_torrent_operations_sequence() {
    let dir    = tempfile::tempdir().unwrap();
    let config = test_config(&dir);
    engine::initialize_engine(config).await.unwrap();

    // 1. Invalid magnet URIs
    assert!(engine::add_magnet(String::new()).await.is_err());
    assert!(engine::add_magnet("https://example.com/file.torrent".into()).await.is_err());

    // 2. Invalid torrent files
    assert!(engine::add_torrent_file(vec![]).await.is_err());
    let garbage: Vec<u8> = (0u8..=127).cycle().take(512).collect();
    assert!(engine::add_torrent_file(garbage).await.is_err());

    // 3. Operations on non-existent torrent ID
    assert!(engine::pause_torrent(999_999).await.is_err());
    assert!(engine::resume_torrent(999_999).await.is_err());
    assert!(engine::remove_torrent(999_999, false).await.is_err());
    assert!(engine::get_torrent_status(999_999).await.is_err());

    engine::shutdown_engine().await.unwrap();
}

#[tokio::test]
#[ignore = "requires network access"]
async fn test_add_real_magnet() {
    const UBUNTU_MAGNET: &str =
        "magnet:?xt=urn:btih:3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c\
         &dn=ubuntu-22.04-desktop-amd64.iso\
         &tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce";

    let dir    = tempfile::tempdir().unwrap();
    let config = EngineConfig {
        download_dir:  dir.path().join("downloads"),
        data_dir:      dir.path().join("data"),
        listen_port:   16003,
        dht_enabled:   true,
        ..EngineConfig::default()
    };
    engine::initialize_engine(config).await.unwrap();

    let id     = engine::add_magnet(UBUNTU_MAGNET.into()).await.unwrap();
    let status = engine::get_torrent_status(id).await.unwrap();

    assert_eq!(status.id, id);

    engine::pause_torrent(id).await.unwrap();
    engine::remove_torrent(id, true).await.unwrap();
    engine::shutdown_engine().await.unwrap();
}
