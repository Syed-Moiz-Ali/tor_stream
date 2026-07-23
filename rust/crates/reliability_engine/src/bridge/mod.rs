//! Public Rust API for reliability_engine.

use std::path::PathBuf;
use std::sync::OnceLock;
use crate::backup::BackupManager;
use crate::health::evaluate_health;
use crate::models::{HealthStatus, SessionSnapshot, StorageReport};
use crate::recovery::RecoveryManager;
use crate::verification::StorageVerifier;

static RECOVERY_MGR: OnceLock<RecoveryManager> = OnceLock::new();

fn get_db_path() -> PathBuf {
    let base = std::env::temp_dir().join("tor_stream_data");
    base.join("session_snapshots.db")
}

fn get_recovery_mgr() -> &'static RecoveryManager {
    RECOVERY_MGR.get_or_init(|| {
        let db_path = get_db_path();
        RecoveryManager::new(&db_path).unwrap()
    })
}

/// Restore the most recent session snapshot.
pub fn restore_session() -> anyhow::Result<Option<SessionSnapshot>> {
    Ok(get_recovery_mgr().restore_latest_session()?)
}

/// Save session snapshot.
pub fn save_session(snapshot: SessionSnapshot) -> anyhow::Result<()> {
    get_recovery_mgr().save_session_state(&snapshot)?;
    Ok(())
}

/// Verify storage and database integrity.
pub fn verify_storage() -> anyhow::Result<StorageReport> {
    let db_path = get_db_path();
    let cache_dir = std::env::temp_dir().join("tor_stream_cache");
    Ok(StorageVerifier::verify_and_repair(&db_path, &cache_dir)?)
}

/// Repair cache files.
pub fn repair_cache() -> anyhow::Result<StorageReport> {
    verify_storage()
}

/// Query system health status.
pub fn health_status() -> anyhow::Result<HealthStatus> {
    Ok(evaluate_health(1))
}

/// Perform immediate database auto-backup.
pub fn backup_now() -> anyhow::Result<String> {
    let db_path = get_db_path();
    let backup_dir = std::env::temp_dir().join("tor_stream_backups");
    let dest = BackupManager::create_backup(&db_path, &backup_dir)?;
    Ok(dest.to_string_lossy().to_string())
}
