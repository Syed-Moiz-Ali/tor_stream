//! SQLite-backed resume data store.
//!
//! Persists torrent metadata and resume payloads between app restarts.
//! All operations use `tokio::task::spawn_blocking` so rusqlite's synchronous
//! API never blocks the Tokio thread pool.
//!
//! ## Schema
//!
//! ```sql
//! torrents    — one row per managed torrent (id, info_hash, name, save_path, status, …)
//! resume_data — opaque resume blobs (torrent_id → BLOB, updated_at)
//! ```

use std::path::Path;
use std::sync::{Arc, Mutex};
use rusqlite::{Connection, params};
use tracing::{debug, info, instrument};
use crate::error::{EngineError, Result};
use crate::models::{TorrentId, TorrentInfo, TorrentStatus};

// ── ResumeStore ────────────────────────────────────────────────────────────────

/// Thread-safe SQLite connection for resume data persistence.
#[derive(Clone)]
pub struct ResumeStore {
    conn: Arc<Mutex<Connection>>,
}

impl ResumeStore {
    /// Open (or create) the database at `db_path` and run migrations.
    pub fn open(db_path: &Path) -> Result<Self> {
        if let Some(parent) = db_path.parent() {
            let _ = std::fs::create_dir_all(parent);
        }

        let conn = Connection::open(db_path)
            .map_err(EngineError::Database)?;

        // Enable WAL mode for better concurrency and crash safety.
        conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;")
            .map_err(EngineError::Database)?;

        let store = Self { conn: Arc::new(Mutex::new(conn)) };
        store.migrate()?;

        info!(?db_path, "Resume store opened");
        Ok(store)
    }

    // ── Migrations ────────────────────────────────────────────────────────────

    fn migrate(&self) -> Result<()> {
        let conn = self.conn.lock().unwrap();
        conn.execute_batch(
            "
            CREATE TABLE IF NOT EXISTS torrents (
                id          INTEGER PRIMARY KEY,
                info_hash   TEXT    NOT NULL,
                name        TEXT,
                save_path   TEXT    NOT NULL DEFAULT '',
                status      TEXT    NOT NULL DEFAULT 'downloading',
                added_at_ms INTEGER NOT NULL,
                total_bytes INTEGER NOT NULL DEFAULT 0
            );

            CREATE INDEX IF NOT EXISTS idx_torrents_info_hash
                ON torrents (info_hash);

            CREATE TABLE IF NOT EXISTS resume_data (
                torrent_id  INTEGER PRIMARY KEY REFERENCES torrents(id) ON DELETE CASCADE,
                data        BLOB    NOT NULL,
                updated_at  INTEGER NOT NULL
            );
            ",
        )
        .map_err(EngineError::Database)
    }

    // ── Torrent CRUD ──────────────────────────────────────────────────────────

    /// Insert or update a torrent record.
    #[instrument(skip(self), fields(id, info_hash))]
    pub async fn upsert_torrent(
        &self,
        id:        TorrentId,
        info_hash: &str,
        name:      Option<&str>,
        save_path: &str,
        added_at_ms: i64,
    ) -> Result<()> {
        let conn      = Arc::clone(&self.conn);
        let info_hash = info_hash.to_owned();
        let name      = name.map(|n| n.to_owned());
        let save_path = save_path.to_owned();

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            conn.execute(
                "INSERT INTO torrents (id, info_hash, name, save_path, added_at_ms)
                 VALUES (?1, ?2, ?3, ?4, ?5)
                 ON CONFLICT(id) DO UPDATE SET
                     info_hash   = excluded.info_hash,
                     name        = COALESCE(excluded.name, torrents.name),
                     save_path   = excluded.save_path",
                params![id as i64, info_hash, name, save_path, added_at_ms],
            )
            .map(|_| ())
            .map_err(EngineError::Database)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))??;

        debug!(id, "Torrent record upserted");
        Ok(())
    }

    /// Update the `name` and `total_bytes` fields once metadata is resolved.
    pub async fn set_metadata(
        &self,
        id:          TorrentId,
        name:        &str,
        total_bytes: u64,
    ) -> Result<()> {
        let conn  = Arc::clone(&self.conn);
        let name  = name.to_owned();

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            conn.execute(
                "UPDATE torrents SET name = ?1, total_bytes = ?2 WHERE id = ?3",
                params![name, total_bytes as i64, id as i64],
            )
            .map(|_| ())
            .map_err(EngineError::Database)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }

    /// Update the status field for a torrent.
    pub async fn set_status(&self, id: TorrentId, status: TorrentStatus) -> Result<()> {
        let conn   = Arc::clone(&self.conn);
        let status = status.as_str().to_owned();

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            conn.execute(
                "UPDATE torrents SET status = ?1 WHERE id = ?2",
                params![status, id as i64],
            )
            .map(|_| ())
            .map_err(EngineError::Database)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }

    /// Delete a torrent record (CASCADE deletes resume_data too).
    pub async fn delete_torrent(&self, id: TorrentId) -> Result<()> {
        let conn = Arc::clone(&self.conn);

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            conn.execute(
                "DELETE FROM torrents WHERE id = ?1",
                params![id as i64],
            )
            .map(|_| ())
            .map_err(EngineError::Database)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }

    /// Load all torrent rows (used when restoring a previous session).
    pub async fn load_all_torrents(&self) -> Result<Vec<StoredTorrent>> {
        let conn = Arc::clone(&self.conn);

        tokio::task::spawn_blocking(move || {
            let conn  = conn.lock().unwrap();
            let mut stmt = conn.prepare(
                "SELECT id, info_hash, name, save_path, status, added_at_ms, total_bytes
                 FROM torrents ORDER BY added_at_ms ASC",
            )?;

            let rows = stmt.query_map([], |row| {
                Ok(StoredTorrent {
                    id:          row.get::<_, i64>(0)? as u64,
                    info_hash:   row.get(1)?,
                    name:        row.get(2)?,
                    save_path:   row.get(3)?,
                    status:      TorrentStatus::from_str(&row.get::<_, String>(4)?),
                    added_at_ms: row.get(5)?,
                    total_bytes: row.get::<_, i64>(6)? as u64,
                })
            })?
            .collect::<std::result::Result<Vec<_>, _>>()?;

            Ok(rows)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }

    // ── Resume data ───────────────────────────────────────────────────────────

    /// Persist raw resume data bytes for a torrent.
    pub async fn save_resume_data(&self, id: TorrentId, data: Vec<u8>) -> Result<()> {
        let conn       = Arc::clone(&self.conn);
        let updated_at = now_ms();

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            conn.execute(
                "INSERT INTO resume_data (torrent_id, data, updated_at)
                 VALUES (?1, ?2, ?3)
                 ON CONFLICT(torrent_id) DO UPDATE SET
                     data       = excluded.data,
                     updated_at = excluded.updated_at",
                params![id as i64, data, updated_at],
            )
            .map(|_| ())
            .map_err(EngineError::Database)
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }

    /// Load the resume data blob for a torrent, if it exists.
    pub async fn load_resume_data(&self, id: TorrentId) -> Result<Option<Vec<u8>>> {
        let conn = Arc::clone(&self.conn);

        tokio::task::spawn_blocking(move || {
            let conn = conn.lock().unwrap();
            let result = conn.query_row(
                "SELECT data FROM resume_data WHERE torrent_id = ?1",
                params![id as i64],
                |row| row.get::<_, Vec<u8>>(0),
            );

            match result {
                Ok(data)                                          => Ok(Some(data)),
                Err(rusqlite::Error::QueryReturnedNoRows)         => Ok(None),
                Err(e)                                            => Err(EngineError::Database(e)),
            }
        })
        .await
        .map_err(|e| EngineError::OperationFailed(e.to_string()))?
    }
}

// ── StoredTorrent ─────────────────────────────────────────────────────────────

/// A row from the `torrents` table, used when restoring a previous session.
#[derive(Debug, Clone)]
pub struct StoredTorrent {
    pub id:          TorrentId,
    pub info_hash:   String,
    pub name:        Option<String>,
    pub save_path:   String,
    pub status:      TorrentStatus,
    pub added_at_ms: i64,
    pub total_bytes: u64,
}

// ── helpers ───────────────────────────────────────────────────────────────────

fn now_ms() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}
