//! Auto-backup snapshot manager.

use std::path::Path;
use tracing::info;
use crate::error::Result;

pub struct BackupManager;

impl BackupManager {
    /// Perform database and session snapshot backup.
    pub fn create_backup(db_path: &Path, backup_dir: &Path) -> Result<PathBuf> {
        let _ = std::fs::create_dir_all(backup_dir);
        let dest = backup_dir.join("torstream_backup.db");
        if db_path.exists() {
            std::fs::copy(db_path, &dest)?;
            info!(?dest, "Auto-backup created successfully");
        }
        Ok(dest)
    }
}

use std::path::PathBuf;
