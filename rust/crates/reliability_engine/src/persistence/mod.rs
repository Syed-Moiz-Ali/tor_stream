//! Session persistence SQLite manager.

use std::path::Path;
use std::sync::{Arc, Mutex};
use rusqlite::{params, Connection};
use tracing::info;

use crate::error::Result;
use crate::models::SessionSnapshot;

/// Thread-safe SQLite store for active session snapshots.
#[derive(Clone)]
pub struct SessionStore {
    conn: Arc<Mutex<Connection>>,
}

impl SessionStore {
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
            "CREATE TABLE IF NOT EXISTS session_snapshots (
                torrent_id INTEGER PRIMARY KEY,
                info_hash TEXT NOT NULL,
                magnet_uri TEXT,
                file_index INTEGER NOT NULL,
                playback_position_bytes INTEGER NOT NULL,
                total_bytes INTEGER NOT NULL,
                selected_audio_track INTEGER NOT NULL,
                selected_subtitle_track INTEGER NOT NULL,
                playback_speed REAL NOT NULL,
                is_playing INTEGER NOT NULL,
                last_active_timestamp_ms INTEGER NOT NULL
            );",
        )?;
        Ok(())
    }

    pub fn save_snapshot(&self, snapshot: &SessionSnapshot) -> Result<()> {
        let guard = self.conn.lock().unwrap();
        guard.execute(
            "INSERT INTO session_snapshots (
                torrent_id, info_hash, magnet_uri, file_index, playback_position_bytes,
                total_bytes, selected_audio_track, selected_subtitle_track, playback_speed,
                is_playing, last_active_timestamp_ms
            ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)
            ON CONFLICT(torrent_id) DO UPDATE SET
                playback_position_bytes=excluded.playback_position_bytes,
                selected_audio_track=excluded.selected_audio_track,
                selected_subtitle_track=excluded.selected_subtitle_track,
                playback_speed=excluded.playback_speed,
                is_playing=excluded.is_playing,
                last_active_timestamp_ms=excluded.last_active_timestamp_ms;",
            params![
                snapshot.torrent_id as i64,
                snapshot.info_hash,
                snapshot.magnet_uri,
                snapshot.file_index,
                snapshot.playback_position_bytes as i64,
                snapshot.total_bytes as i64,
                snapshot.selected_audio_track,
                snapshot.selected_subtitle_track,
                snapshot.playback_speed,
                if snapshot.is_playing { 1 } else { 0 },
                snapshot.last_active_timestamp_ms,
            ],
        )?;
        info!(torrent_id = snapshot.torrent_id, "Session snapshot persisted");
        Ok(())
    }

    pub fn load_latest_snapshot(&self) -> Result<Option<SessionSnapshot>> {
        let guard = self.conn.lock().unwrap();
        let mut stmt = guard.prepare(
            "SELECT torrent_id, info_hash, magnet_uri, file_index, playback_position_bytes,
                    total_bytes, selected_audio_track, selected_subtitle_track, playback_speed,
                    is_playing, last_active_timestamp_ms
             FROM session_snapshots
             ORDER BY last_active_timestamp_ms DESC
             LIMIT 1;",
        )?;

        let mut rows = stmt.query([])?;
        if let Some(row) = rows.next()? {
            let is_playing_int: i32 = row.get(9)?;
            Ok(Some(SessionSnapshot {
                torrent_id: row.get::<_, i64>(0)? as u64,
                info_hash: row.get(1)?,
                magnet_uri: row.get(2)?,
                file_index: row.get(3)?,
                playback_position_bytes: row.get::<_, i64>(4)? as u64,
                total_bytes: row.get::<_, i64>(5)? as u64,
                selected_audio_track: row.get(6)?,
                selected_subtitle_track: row.get(7)?,
                playback_speed: row.get(8)?,
                is_playing: is_playing_int != 0,
                last_active_timestamp_ms: row.get(10)?,
            }))
        } else {
            Ok(None)
        }
    }
}
