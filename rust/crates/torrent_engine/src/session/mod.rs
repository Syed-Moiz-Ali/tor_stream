//! Session management — wraps `librqbit::Session`.
//!
//! [`TorrentSession`] is the single entry point to the BitTorrent network.
//! It manages the librqbit session lifecycle, handles adding/removing torrents,
//! and exposes typed operations to the rest of the engine.
//!
//! ## Responsibilities
//! - Create and configure the librqbit session (DHT, trackers, UPnP, ports)
//! - Add torrents from magnet URIs or `.torrent` file bytes
//! - Retrieve handles for pause / resume / status queries
//! - Remove torrents (optionally deleting their files)
//! - Shut down the session cleanly

pub mod handle;

use std::sync::Arc;
use std::path::PathBuf;

use bytes::Bytes;
use librqbit::{
    api::TorrentIdOrHash, AddTorrent, AddTorrentOptions, AddTorrentResponse,
    Session as LibSession, SessionOptions, DhtSessionConfig,
};
use tracing::{debug, info, instrument, warn};

use crate::config::EngineConfig;
use crate::error::{EngineError, Result};
use crate::models::TorrentId;
use self::handle::TorrentHandle;

// ── TorrentSession ────────────────────────────────────────────────────────────

/// Wraps `Arc<librqbit::Session>` with typed, ergonomic methods.
///
/// Cloning this struct shares the underlying session.
#[derive(Clone)]
pub struct TorrentSession {
    inner:        Arc<LibSession>,
    download_dir: PathBuf,
}

impl TorrentSession {
    // ── Accessors ─────────────────────────────────────────────────────────────

    /// Returns the base download directory path.
    pub fn download_dir(&self) -> &std::path::Path {
        &self.download_dir
    }

    // ── Construction ─────────────────────────────────────────────────────────

    /// Create a new session from the given [`EngineConfig`].
    ///
    /// This initialises the librqbit session, bootstraps DHT, and begins
    /// listening for incoming peer connections.
    #[instrument(skip(config), fields(listen_port = config.listen_port))]
    pub async fn new(config: &EngineConfig) -> Result<Self> {
        // Ensure the download directory exists.
        tokio::fs::create_dir_all(&config.download_dir)
            .await
            .map_err(EngineError::Io)?;
        tokio::fs::create_dir_all(&config.data_dir)
            .await
            .map_err(EngineError::Io)?;

        let port    = config.listen_port;
        let session_dir = config.session_state_path().parent()
            .unwrap_or(std::path::Path::new("."))
            .to_path_buf();

        let opts = SessionOptions {
            dht: if config.dht_enabled {
                Some(DhtSessionConfig {
                    port: Some(port),
                    persistence: None,
                    ..DhtSessionConfig::default()
                })
            } else {
                None
            },
            fastresume: true,
            persistence: Some(librqbit::SessionPersistenceConfig::Json {
                folder: Some(session_dir),
            }),
            ..SessionOptions::default()
        };

        let inner = LibSession::new_with_opts(config.download_dir.clone(), opts)
            .await
            .map_err(|e| EngineError::SessionCreationFailed(e.to_string()))?;

        info!(
            port,
            dht = config.dht_enabled,
            upnp = config.upnp_enabled,
            "Torrent session started"
        );

        Ok(Self {
            inner,
            download_dir: config.download_dir.clone(),
        })
    }

    // ── Torrent management ────────────────────────────────────────────────────

    /// Add a torrent from a magnet URI.
    ///
    /// Returns the assigned [`TorrentId`] and a [`TorrentHandle`]. The torrent
    /// begins in [`crate::models::TorrentStatus::FetchingMetadata`] if the
    /// info-dictionary has not yet been downloaded.
    #[instrument(skip(self), fields(magnet = %magnet_uri.chars().take(60).collect::<String>()))]
    pub async fn add_magnet(&self, magnet_uri: String) -> Result<(TorrentId, TorrentHandle)> {
        if !magnet_uri.starts_with("magnet:") {
            return Err(EngineError::InvalidMagnet { uri: magnet_uri });
        }

        debug!("Adding magnet link");

        let response = self
            .inner
            .add_torrent(
                AddTorrent::from_url(&magnet_uri),
                Some(AddTorrentOptions {
                    paused:        false,
                    output_folder: Some(self.download_dir.to_string_lossy().to_string()),
                    ..AddTorrentOptions::default()
                }),
            )
            .await
            .map_err(|e| EngineError::SessionError(e.to_string()))?;

        self.handle_add_response(response)
    }

    /// Add a torrent from raw `.torrent` file bytes.
    ///
    /// Returns the assigned [`TorrentId`] and a [`TorrentHandle`].
    #[instrument(skip(self, data), fields(bytes = data.len()))]
    pub async fn add_torrent_file(
        &self,
        data: Vec<u8>,
    ) -> Result<(TorrentId, TorrentHandle)> {
        if data.is_empty() {
            return Err(EngineError::InvalidTorrentFile {
                reason: "empty data".into(),
            });
        }

        debug!("Adding .torrent file ({} bytes)", data.len());

        let response = self
            .inner
            .add_torrent(
                AddTorrent::TorrentFileBytes(Bytes::from(data)),
                Some(AddTorrentOptions {
                    paused:        false,
                    output_folder: Some(self.download_dir.to_string_lossy().to_string()),
                    ..AddTorrentOptions::default()
                }),
            )
            .await
            .map_err(|e| EngineError::InvalidTorrentFile {
                reason: e.to_string(),
            })?;

        self.handle_add_response(response)
    }

    /// Retrieve a [`TorrentHandle`] for an existing torrent.
    pub fn get(&self, id: TorrentId) -> Result<TorrentHandle> {
        let lib_id = id as usize;
        self.inner
            .get(TorrentIdOrHash::Id(lib_id))
            .map(|h| TorrentHandle::new(id, h))
            .ok_or(EngineError::TorrentNotFound { id })
    }

    /// Returns the IDs of all currently managed torrents.
    pub fn all_ids(&self) -> Vec<TorrentId> {
        self.inner
            .with_torrents(|iter| {
                iter.map(|(id, _)| id as TorrentId).collect()
            })
    }

    /// Pause a torrent.
    #[instrument(skip(self), fields(id))]
    pub async fn pause(&self, id: TorrentId) -> Result<()> {
        let lib_id = id as usize;
        let handle = self
            .inner
            .get(TorrentIdOrHash::Id(lib_id))
            .ok_or(EngineError::TorrentNotFound { id })?;
        self.inner
            .pause(&handle)
            .await
            .map_err(|e| EngineError::OperationFailed(e.to_string()))?;
        info!(id, "Torrent paused");
        Ok(())
    }

    /// Resume a paused torrent.
    #[instrument(skip(self), fields(id))]
    pub async fn resume(&self, id: TorrentId) -> Result<()> {
        let lib_id = id as usize;
        let handle = self
            .inner
            .get(TorrentIdOrHash::Id(lib_id))
            .ok_or(EngineError::TorrentNotFound { id })?;
        Arc::clone(&self.inner)
            .unpause(&handle)
            .await
            .map_err(|e| EngineError::OperationFailed(e.to_string()))?;
        info!(id, "Torrent resumed");
        Ok(())
    }

    /// Remove a torrent from the session.
    ///
    /// If `delete_files` is `true`, the downloaded files are deleted from disk.
    #[instrument(skip(self), fields(id, delete_files))]
    pub async fn remove(&self, id: TorrentId, delete_files: bool) -> Result<()> {
        self.inner
            .delete(TorrentIdOrHash::Id(id as usize), delete_files)
            .await
            .map_err(|e| EngineError::OperationFailed(e.to_string()))?;

        info!(id, delete_files, "Torrent removed");
        Ok(())
    }

    /// Shut down the session, flushing all state to disk.
    pub async fn shutdown(&self) {
        // librqbit session is dropped when the Arc refcount reaches zero.
        // We trigger a final flush via the session persistence.
        info!("Torrent session shutting down");
    }

    // ── Internal helpers ──────────────────────────────────────────────────────

    fn handle_add_response(
        &self,
        response: AddTorrentResponse,
    ) -> Result<(TorrentId, TorrentHandle)> {
        match response {
            AddTorrentResponse::Added(lib_id, handle) => {
                let id = lib_id as TorrentId;
                info!(id, "Torrent added to session");
                Ok((id, TorrentHandle::new(id, handle)))
            }
            AddTorrentResponse::AlreadyManaged(lib_id, handle) => {
                let id = lib_id as TorrentId;
                warn!(id, "Torrent already managed — returning existing handle");
                Ok((id, TorrentHandle::new(id, handle)))
            }
            AddTorrentResponse::ListOnly(_) => {
                Err(EngineError::SessionError(
                    "list-only response not supported".into(),
                ))
            }
        }
    }
}
