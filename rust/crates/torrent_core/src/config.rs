//! Application configuration.
//!
//! All config is loaded once at startup from `config.toml` in Android's
//! `filesDir`. Changes are applied via [`ConfigManager::reload`].
//! The [`AppConfig`] struct is the single source of truth.

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

// ── Top-level config ──────────────────────────────────────────────────────────

/// Complete application configuration.
///
/// Serialized as TOML. Stored at `<filesDir>/config.toml` on Android.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct AppConfig {
    pub session:   SessionConfig,
    pub streaming: StreamingConfig,
    pub storage:   StorageConfig,
    pub network:   NetworkConfig,
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            session:   SessionConfig::default(),
            streaming: StreamingConfig::default(),
            storage:   StorageConfig::default(),
            network:   NetworkConfig::default(),
        }
    }
}

// ── Session config ────────────────────────────────────────────────────────────

/// libtorrent session parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct SessionConfig {
    /// Maximum peer connections across all torrents. Default: 200.
    pub max_connections: u32,
    /// Upload slots (peers we upload to). Default: 8.
    pub max_upload_slots: u32,
    /// Upload rate limit in bytes/s. 0 = unlimited.
    pub upload_rate_limit: i64,
    /// Download rate limit in bytes/s. 0 = unlimited.
    pub download_rate_limit: i64,
    /// Enable DHT (distributed hash table). Default: true.
    pub dht_enabled: bool,
    /// Enable peer exchange (PEX). Default: true.
    pub peer_exchange: bool,
    /// Enable local service discovery. Default: true.
    pub local_service_discovery: bool,
}

impl Default for SessionConfig {
    fn default() -> Self {
        Self {
            max_connections:          200,
            max_upload_slots:         8,
            upload_rate_limit:        0,
            download_rate_limit:      0,
            dht_enabled:              true,
            peer_exchange:            true,
            local_service_discovery:  true,
        }
    }
}

// ── Streaming config ──────────────────────────────────────────────────────────

/// HTTP streaming server + piece scheduler parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct StreamingConfig {
    /// Port for the local HTTP streaming server. Default: 18765.
    /// Always bound to 127.0.0.1 — never exposed to the network.
    pub http_port: u16,
    /// Seconds ahead of playback head to keep at max priority (zone A).
    pub immediate_window_seconds: u32,
    /// Seconds ahead at high priority (zone B). Default: 120.
    pub near_window_seconds: u32,
    /// Seconds ahead at low priority (zone C). Default: 600.
    pub far_window_seconds: u32,
    /// Milliseconds of buffering stall before triggering recovery. Default: 5000.
    pub stall_timeout_ms: u64,
}

impl Default for StreamingConfig {
    fn default() -> Self {
        Self {
            http_port:                18765,
            immediate_window_seconds: 30,
            near_window_seconds:      120,
            far_window_seconds:       600,
            stall_timeout_ms:         5_000,
        }
    }
}

// ── Storage config ────────────────────────────────────────────────────────────

/// File system + database parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct StorageConfig {
    /// Default directory for downloaded torrent files.
    pub download_dir: PathBuf,
    /// Directory for SQLite database and resume data.
    pub data_dir: PathBuf,
    /// Maximum disk space for downloaded files (GB). Default: 10.0.
    pub max_cache_gb: f32,
    /// How often to flush resume data to SQLite (seconds). Default: 60.
    pub resume_data_interval_s: u32,
}

impl Default for StorageConfig {
    fn default() -> Self {
        // Paths are overridden at runtime with platform-specific directories.
        Self {
            download_dir:            PathBuf::from("downloads"),
            data_dir:                PathBuf::from("data"),
            max_cache_gb:            10.0,
            resume_data_interval_s:  60,
        }
    }
}

// ── Network config ────────────────────────────────────────────────────────────

/// Network-level parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct NetworkConfig {
    /// Port libtorrent listens on for incoming peer connections. Default: 6881.
    pub listen_port: u16,
    /// Enable UPnP port mapping. Default: true.
    pub use_upnp: bool,
    /// Enable NAT-PMP port mapping. Default: true.
    pub use_natpmp: bool,
}

impl Default for NetworkConfig {
    fn default() -> Self {
        Self {
            listen_port: 6881,
            use_upnp:    true,
            use_natpmp:  true,
        }
    }
}

// ── ConfigManager ─────────────────────────────────────────────────────────────

/// Manages loading, validating, and hot-reloading [`AppConfig`].
pub struct ConfigManager {
    config: AppConfig,
    path:   PathBuf,
}

impl ConfigManager {
    /// Load config from `path`. Falls back to [`AppConfig::default`] if the
    /// file does not exist or cannot be parsed.
    pub fn load(path: PathBuf) -> Self {
        let config = std::fs::read_to_string(&path)
            .ok()
            .and_then(|s| toml::from_str::<AppConfig>(&s).ok())
            .unwrap_or_default();

        tracing::info!(?path, "Config loaded");
        Self { config, path }
    }

    /// Returns a snapshot of the current config.
    pub fn get(&self) -> &AppConfig {
        &self.config
    }

    /// Reload config from disk and return the new snapshot.
    pub fn reload(&mut self) -> crate::error::Result<&AppConfig> {
        let raw = std::fs::read_to_string(&self.path)
            .map_err(crate::error::TorStreamError::Io)?;
        self.config = toml::from_str::<AppConfig>(&raw)
            .map_err(|e| crate::error::TorStreamError::Config(e.to_string()))?;
        tracing::info!("Config reloaded");
        Ok(&self.config)
    }

    /// Persist the current config to disk.
    pub fn save(&self) -> crate::error::Result<()> {
        let raw = toml::to_string_pretty(&self.config)
            .map_err(|e| crate::error::TorStreamError::Config(e.to_string()))?;
        std::fs::write(&self.path, raw).map_err(crate::error::TorStreamError::Io)
    }
}
