//! Session startup and lifecycle tests.

use torrent_engine::{EngineConfig, bridge as engine};

fn test_config(dir: &tempfile::TempDir) -> EngineConfig {
    EngineConfig {
        download_dir: dir.path().join("downloads"),
        data_dir:     dir.path().join("data"),
        listen_port:  16001,
        dht_enabled:  false,
        lsd_enabled:  false,
        upnp_enabled: false,
        natpmp_enabled: false,
        ..EngineConfig::default()
    }
}

#[tokio::test]
async fn test_config_validation_rejects_port_zero() {
    let dir = tempfile::tempdir().unwrap();
    let config = EngineConfig {
        download_dir: dir.path().join("downloads"),
        data_dir:     dir.path().join("data"),
        listen_port:  0,
        dht_enabled:  false,
        ..EngineConfig::default()
    };
    let result = engine::initialize_engine(config).await;
    assert!(result.is_err(), "Expected error for listen_port=0");
}

#[tokio::test]
async fn test_engine_lifecycle_sequence() {
    let dir    = tempfile::tempdir().unwrap();
    let config = test_config(&dir);
    let dl_dir = config.download_dir.clone();

    // 1. Initialize
    let init_res = engine::initialize_engine(config).await;
    assert!(init_res.is_ok(), "Engine initialisation failed: {:?}", init_res.err());

    // 2. Verify DB file creation
    assert!(dir.path().join("data").join("torstream.db").exists());

    // 3. Verify download dir creation
    assert!(dl_dir.exists());

    // 4. Verify empty torrent list on fresh start
    let torrents = engine::get_all_torrents().await.unwrap();
    assert!(torrents.is_empty());

    // 5. Shutdown and verify idempotency
    engine::shutdown_engine().await.unwrap();
    let _ = engine::shutdown_engine().await;
}
