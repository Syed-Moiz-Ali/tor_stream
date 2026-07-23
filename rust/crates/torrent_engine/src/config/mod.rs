//! Engine configuration.
//!
//! [`EngineConfig`] is the single source of truth for all tunable parameters.
//! It is passed to [`crate::bridge::initialize_engine`] once at startup and
//! stored inside the engine singleton.

use std::path::PathBuf;
use serde::{Deserialize, Serialize};

/// Complete configuration for the TorStream torrent engine.
///
/// All fields have sensible defaults via [`Default`]. Override only what you
/// need in the Flutter `EngineConfig` Dart class.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EngineConfig {
    // ── Storage ───────────────────────────────────────────────────────────────
    /// Directory where downloaded files are saved.
    pub download_dir: PathBuf,
    /// Directory for the SQLite database and session state files.
    pub data_dir: PathBuf,

    // ── Network ───────────────────────────────────────────────────────────────
    /// Port libtorrent listens on for incoming peer connections.
    pub listen_port: u16,
    /// Maximum simultaneous peer connections. 0 = unlimited.
    pub max_connections: u32,
    /// Upload rate cap in bytes/s. 0 = unlimited.
    pub upload_rate_limit: u64,
    /// Download rate cap in bytes/s. 0 = unlimited.
    pub download_rate_limit: u64,

    // ── Protocol features ─────────────────────────────────────────────────────
    /// Enable the Distributed Hash Table for trackerless torrents.
    pub dht_enabled: bool,
    /// Enable Local Service Discovery (peer discovery on the LAN).
    pub lsd_enabled: bool,
    /// Enable UPnP port forwarding.
    pub upnp_enabled: bool,
    /// Enable NAT-PMP port forwarding.
    pub natpmp_enabled: bool,
    /// Hide client identity from trackers (use a random peer-ID per torrent).
    pub anonymous_mode: bool,

    // ── Performance ───────────────────────────────────────────────────────────
    /// In-memory read cache size in MiB. 0 = no caching.
    pub cache_size_mb: u32,
}

impl Default for EngineConfig {
    fn default() -> Self {
        Self {
            download_dir:        PathBuf::from("downloads"),
            data_dir:            PathBuf::from("data"),
            listen_port:         6881,
            max_connections:     200,
            upload_rate_limit:   0,
            download_rate_limit: 0,
            dht_enabled:         true,
            lsd_enabled:         true,
            upnp_enabled:        true,
            natpmp_enabled:      true,
            anonymous_mode:      false,
            cache_size_mb:       64,
        }
    }
}

impl EngineConfig {
    /// Validate the configuration, returning an error if any value is invalid.
    pub fn validate(&self) -> crate::error::Result<()> {
        if self.listen_port == 0 {
            return Err(crate::error::EngineError::InvalidConfig(
                "listen_port must be > 0".into(),
            ));
        }
        Ok(())
    }

    /// Path to the SQLite database file.
    pub fn db_path(&self) -> PathBuf {
        self.data_dir.join("torstream.db")
    }

    /// Path to the librqbit session state file (fast-resume).
    pub fn session_state_path(&self) -> PathBuf {
        self.data_dir.join("session.json")
    }
}
