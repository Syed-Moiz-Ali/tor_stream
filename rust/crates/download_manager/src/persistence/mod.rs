//! SQLite persistence store for downloads, library items, history, and settings.

use std::path::Path;
use std::sync::{Arc, Mutex};
use rusqlite::{params, Connection};
use crate::error::Result;
use crate::models::{
    ContinueWatchingItem, DownloadState, DownloadTask, LibraryItem,
    MediaCategory, QueuePriority,
};

/// Thread-safe SQLite database manager for download library.
#[derive(Clone)]
pub struct LibraryStore {
    conn: Arc<Mutex<Connection>>,
}

impl LibraryStore {
    pub fn open(db_path: &Path) -> Result<Self> {
        if let Some(parent) = db_path.parent() {
            let _ = std::fs::create_dir_all(parent);
        }

        let conn = Connection::open(db_path)?;
        conn.execute_batch("PRAGMA journal_mode=WAL;")?;

        let store = Self {
            conn: Arc::new(Mutex::new(conn)),
        };
        store.migrate()?;
        Ok(store)
    }

    fn migrate(&self) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute_batch(
            "CREATE TABLE IF NOT EXISTS downloads (
                id INTEGER PRIMARY KEY,
                torrent_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                save_path TEXT NOT NULL,
                total_bytes INTEGER NOT NULL,
                downloaded_bytes INTEGER NOT NULL,
                progress REAL NOT NULL,
                download_speed_bps INTEGER NOT NULL,
                priority INTEGER NOT NULL,
                state INTEGER NOT NULL,
                added_at_ms INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS library (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                torrent_id INTEGER NOT NULL UNIQUE,
                title TEXT NOT NULL,
                category INTEGER NOT NULL,
                primary_file_index INTEGER NOT NULL,
                total_bytes INTEGER NOT NULL,
                artwork_path TEXT,
                is_favorite INTEGER NOT NULL,
                date_added_ms INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS continue_watching (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                torrent_id INTEGER NOT NULL,
                file_index INTEGER NOT NULL,
                title TEXT NOT NULL,
                artwork_path TEXT,
                position_ms INTEGER NOT NULL,
                duration_ms INTEGER NOT NULL,
                progress_pct REAL NOT NULL,
                last_played_ms INTEGER NOT NULL,
                UNIQUE(torrent_id, file_index)
            );",
        )?;
        Ok(())
    }

    pub fn upsert_download(&self, task: &DownloadTask) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT INTO downloads (
                id, torrent_id, title, save_path, total_bytes, downloaded_bytes,
                progress, download_speed_bps, priority, state, added_at_ms
            ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)
            ON CONFLICT(id) DO UPDATE SET
                downloaded_bytes=excluded.downloaded_bytes,
                progress=excluded.progress,
                download_speed_bps=excluded.download_speed_bps,
                priority=excluded.priority,
                state=excluded.state;",
            params![
                task.id as i64,
                task.torrent_id as i64,
                task.title,
                task.save_path,
                task.total_bytes as i64,
                task.downloaded_bytes as i64,
                task.progress,
                task.download_speed_bps as i64,
                task.priority as i32,
                task.state as i32,
                task.added_at_ms,
            ],
        )?;
        Ok(())
    }

    pub fn load_all_downloads(&self) -> Result<Vec<DownloadTask>> {
        let guard = self.conn.lock().unwrap();
        let mut stmt = guard.prepare(
            "SELECT id, torrent_id, title, save_path, total_bytes, downloaded_bytes,
                    progress, download_speed_bps, priority, state, added_at_ms
             FROM downloads
             ORDER BY priority DESC, added_at_ms ASC;",
        )?;

        let rows = stmt.query_map([], |row| {
            let prio_int: i32 = row.get(8)?;
            let state_int: i32 = row.get(9)?;
            Ok(DownloadTask {
                id: row.get::<_, i64>(0)? as u64,
                torrent_id: row.get::<_, i64>(1)? as u64,
                title: row.get(2)?,
                save_path: row.get(3)?,
                total_bytes: row.get::<_, i64>(4)? as u64,
                downloaded_bytes: row.get::<_, i64>(5)? as u64,
                progress: row.get(6)?,
                download_speed_bps: row.get::<_, i64>(7)? as u64,
                priority: match prio_int {
                    4 => QueuePriority::Highest,
                    3 => QueuePriority::High,
                    1 => QueuePriority::Low,
                    0 => QueuePriority::Lowest,
                    _ => QueuePriority::Normal,
                },
                state: match state_int {
                    1 => DownloadState::Downloading,
                    2 => DownloadState::Paused,
                    3 => DownloadState::Completed,
                    4 => DownloadState::Failed,
                    5 => DownloadState::Cancelled,
                    _ => DownloadState::Queued,
                },
                added_at_ms: row.get(10)?,
            })
        })?;

        let mut tasks = Vec::new();
        for r in rows {
            tasks.push(r?);
        }
        Ok(tasks)
    }

    pub fn upsert_library_item(&self, item: &LibraryItem) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT INTO library (
                torrent_id, title, category, primary_file_index, total_bytes,
                artwork_path, is_favorite, date_added_ms
            ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
            ON CONFLICT(torrent_id) DO UPDATE SET
                is_favorite=excluded.is_favorite;",
            params![
                item.torrent_id as i64,
                item.title,
                item.category as i32,
                item.primary_file_index,
                item.total_bytes as i64,
                item.artwork_path,
                if item.is_favorite { 1 } else { 0 },
                item.date_added_ms,
            ],
        )?;
        Ok(())
    }

    pub fn load_library_items(&self) -> Result<Vec<LibraryItem>> {
        let guard = self.conn.lock().unwrap();
        let mut stmt = guard.prepare(
            "SELECT id, torrent_id, title, category, primary_file_index, total_bytes,
                    artwork_path, is_favorite, date_added_ms
             FROM library
             ORDER BY date_added_ms DESC;",
        )?;

        let rows = stmt.query_map([], |row| {
            let cat_int: i32 = row.get(3)?;
            let is_fav_int: i32 = row.get(7)?;
            Ok(LibraryItem {
                id: row.get::<_, i64>(0)? as u64,
                torrent_id: row.get::<_, i64>(1)? as u64,
                title: row.get(2)?,
                category: match cat_int {
                    0 => MediaCategory::Movie,
                    1 => MediaCategory::TvShow,
                    2 => MediaCategory::Anime,
                    3 => MediaCategory::Documentary,
                    4 => MediaCategory::MusicVideo,
                    _ => MediaCategory::Other,
                },
                primary_file_index: row.get(4)?,
                total_bytes: row.get::<_, i64>(5)? as u64,
                artwork_path: row.get(6)?,
                is_favorite: is_fav_int != 0,
                date_added_ms: row.get(8)?,
            })
        })?;

        let mut items = Vec::new();
        for r in rows {
            items.push(r?);
        }
        Ok(items)
    }

    pub fn upsert_continue_watching(&self, item: &ContinueWatchingItem) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT INTO continue_watching (
                torrent_id, file_index, title, artwork_path, position_ms, duration_ms, progress_pct, last_played_ms
            ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
            ON CONFLICT(torrent_id, file_index) DO UPDATE SET
                position_ms=excluded.position_ms,
                duration_ms=excluded.duration_ms,
                progress_pct=excluded.progress_pct,
                last_played_ms=excluded.last_played_ms;",
            params![
                item.torrent_id as i64,
                item.file_index,
                item.title,
                item.artwork_path,
                item.position_ms as i64,
                item.duration_ms as i64,
                item.progress_pct,
                item.last_played_ms,
            ],
        )?;
        Ok(())
    }

    pub fn load_continue_watching(&self) -> Result<Vec<ContinueWatchingItem>> {
        let guard = self.conn.lock().unwrap();
        let mut stmt = guard.prepare(
            "SELECT id, torrent_id, file_index, title, artwork_path, position_ms, duration_ms, progress_pct, last_played_ms
             FROM continue_watching
             ORDER BY last_played_ms DESC;",
        )?;

        let rows = stmt.query_map([], |row| {
            Ok(ContinueWatchingItem {
                id: row.get::<_, i64>(0)? as u64,
                torrent_id: row.get::<_, i64>(1)? as u64,
                file_index: row.get(2)?,
                title: row.get(3)?,
                artwork_path: row.get(4)?,
                position_ms: row.get::<_, i64>(5)? as u64,
                duration_ms: row.get::<_, i64>(6)? as u64,
                progress_pct: row.get(7)?,
                last_played_ms: row.get(8)?,
            })
        })?;

        let mut items = Vec::new();
        for r in rows {
            items.push(r?);
        }
        Ok(items)
    }
}
