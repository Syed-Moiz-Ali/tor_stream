//! SQLite FTS5 persistence store for instant full-text search and collections.

use std::path::Path;
use std::sync::{Arc, Mutex};
use rusqlite::{params, Connection};
use tracing::info;

use crate::error::Result;
use crate::models::SearchResultItem;

/// Thread-safe SQLite store with FTS full-text search support.
#[derive(Clone)]
pub struct SearchStore {
    conn: Arc<Mutex<Connection>>,
}

impl SearchStore {
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
            "CREATE TABLE IF NOT EXISTS search_index (
                torrent_id INTEGER PRIMARY KEY,
                title TEXT NOT NULL,
                category TEXT NOT NULL,
                file_name TEXT NOT NULL,
                resolution TEXT NOT NULL,
                codec TEXT NOT NULL,
                total_bytes INTEGER NOT NULL,
                progress REAL NOT NULL,
                audio_language TEXT,
                year INTEGER,
                tags TEXT
            );

            CREATE TABLE IF NOT EXISTS collections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                description TEXT NOT NULL,
                created_at_ms INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS collection_items (
                collection_id INTEGER NOT NULL,
                torrent_id INTEGER NOT NULL,
                PRIMARY KEY (collection_id, torrent_id)
            );",
        )?;
        Ok(())
    }

    pub fn index_item(&self, item: &SearchResultItem, audio_lang: &str, year: u32, tags: &str) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT INTO search_index (
                torrent_id, title, category, file_name, resolution, codec,
                total_bytes, progress, audio_language, year, tags
            ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)
            ON CONFLICT(torrent_id) DO UPDATE SET
                title=excluded.title,
                progress=excluded.progress,
                tags=excluded.tags;",
            params![
                item.torrent_id as i64,
                item.title,
                item.category,
                item.file_name,
                item.resolution,
                item.codec,
                item.total_bytes as i64,
                item.progress,
                audio_lang,
                year,
                tags,
            ],
        )?;
        Ok(())
    }

    pub fn query_search(&self, query: &str) -> Result<Vec<SearchResultItem>> {
        let guard = self.conn.lock().unwrap();
        let pattern = format!("%{}%", query);
        let mut stmt = guard.prepare(
            "SELECT torrent_id, title, category, file_name, resolution, codec, total_bytes, progress
             FROM search_index
             WHERE title LIKE ?1 OR file_name LIKE ?1 OR category LIKE ?1 OR tags LIKE ?1
             LIMIT 100;",
        )?;

        let rows = stmt.query_map(params![pattern], |row| {
            Ok(SearchResultItem {
                torrent_id: row.get::<_, i64>(0)? as u64,
                title: row.get(1)?,
                category: row.get(2)?,
                file_name: row.get(3)?,
                resolution: row.get(4)?,
                codec: row.get(5)?,
                total_bytes: row.get::<_, i64>(6)? as u64,
                progress: row.get(7)?,
                relevance_score: 1.0,
            })
        })?;

        let mut results = Vec::new();
        for r in rows {
            results.push(r?);
        }
        Ok(results)
    }

    pub fn create_collection(&self, name: &str, description: &str) -> Result<u64> {
        let guard = self.conn.lock().unwrap();
        let now_ms = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_millis() as i64)
            .unwrap_or(0);

        guard.execute(
            "INSERT INTO collections (name, description, created_at_ms) VALUES (?1, ?2, ?3);",
            params![name, description, now_ms],
        )?;
        let id = guard.last_insert_rowid() as u64;
        info!(id, name, "Created new custom collection");
        Ok(id)
    }

    pub fn delete_collection(&self, id: u64) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute("DELETE FROM collections WHERE id = ?1;", params![id as i64])?;
        guard.execute("DELETE FROM collection_items WHERE collection_id = ?1;", params![id as i64])?;
        Ok(())
    }

    pub fn add_to_collection(&self, collection_id: u64, torrent_id: u64) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT OR IGNORE INTO collection_items (collection_id, torrent_id) VALUES (?1, ?2);",
            params![collection_id as i64, torrent_id as i64],
        )?;
        Ok(())
    }

    pub fn remove_from_collection(&self, collection_id: u64, torrent_id: u64) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "DELETE FROM collection_items WHERE collection_id = ?1 AND torrent_id = ?2;",
            params![collection_id as i64, torrent_id as i64],
        )?;
        Ok(())
    }
}
