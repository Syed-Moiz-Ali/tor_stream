//! Shared data models for the torrent engine.
//!
//! These types are used internally across all engine modules. The FFI bridge
//! converts them to Flutter-safe types before crossing the FRB boundary.

use serde::{Deserialize, Serialize};

// ── TorrentId ──────────────────────────────────────────────────────────────────

/// Stable identifier for a managed torrent.
///
/// Corresponds to librqbit's internal sequential `TorrentId: usize`,
/// cast to `u64` for FFI safety.
pub type TorrentId = u64;

// ── TorrentStatus ─────────────────────────────────────────────────────────────

/// High-level lifecycle state of a torrent.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum TorrentStatus {
    /// Session has accepted the torrent; waiting to start.
    Queued,
    /// Checking local files against piece hashes.
    Checking,
    /// Downloading torrent metadata (magnet link, no .torrent file yet).
    FetchingMetadata,
    /// Actively downloading pieces from peers.
    Downloading,
    /// Download complete; now uploading (seeding) to other peers.
    Seeding,
    /// Explicitly paused by the user.
    Paused,
    /// A non-recoverable error occurred.
    Error,
}

impl TorrentStatus {
    /// Returns `true` if the torrent is transferring data (either direction).
    pub fn is_active(&self) -> bool {
        matches!(self, Self::Downloading | Self::Seeding | Self::Checking)
    }

    /// Canonical string label used in SQLite `status` column.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Queued           => "queued",
            Self::Checking         => "checking",
            Self::FetchingMetadata => "fetching_metadata",
            Self::Downloading      => "downloading",
            Self::Seeding          => "seeding",
            Self::Paused           => "paused",
            Self::Error            => "error",
        }
    }

    /// Parse from the SQLite label.
    pub fn from_str(s: &str) -> Self {
        match s {
            "queued"            => Self::Queued,
            "checking"          => Self::Checking,
            "fetching_metadata" => Self::FetchingMetadata,
            "downloading"       => Self::Downloading,
            "seeding"           => Self::Seeding,
            "paused"            => Self::Paused,
            _                   => Self::Error,
        }
    }
}

// ── TorrentInfo ────────────────────────────────────────────────────────────────

/// A snapshot of a torrent's current state.
///
/// Produced by [`crate::bridge::get_torrent_status`] and
/// [`crate::bridge::get_all_torrents`]. Polled every 2 seconds by the
/// background task and published as [`crate::events::EngineEvent::ProgressUpdate`].
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TorrentInfo {
    /// Internal numeric ID (librqbit `TorrentId` as `u64`).
    pub id: TorrentId,
    /// 40-hex-character SHA-1 info-hash string.
    pub info_hash: String,
    /// Display name from torrent metadata, or `None` while fetching.
    pub name: Option<String>,
    /// Current lifecycle state.
    pub status: TorrentStatus,
    /// Download progress in `[0.0, 1.0]`.
    pub progress: f64,
    /// Current download throughput in bytes/s.
    pub download_rate: u64,
    /// Current upload throughput in bytes/s.
    pub upload_rate: u64,
    /// Total content size in bytes.
    pub total_bytes: u64,
    /// Bytes downloaded and verified so far.
    pub downloaded_bytes: u64,
    /// Number of peers we are currently exchanging data with.
    pub num_peers: u32,
    /// Filesystem path where the torrent is being saved.
    pub save_path: String,
    /// Unix epoch milliseconds when the torrent was added.
    pub added_at_ms: i64,
}

// ── PeerInfo ───────────────────────────────────────────────────────────────────

/// Statistics about peer connections for a single torrent.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PeerStats {
    /// Peers queued for connection.
    pub queued: u32,
    /// Peers currently connecting (TCP handshake in progress).
    pub connecting: u32,
    /// Peers with an active BitTorrent session.
    pub live: u32,
    /// Total unique peers seen since the torrent was added.
    pub seen: u32,
    /// Peers that have been disconnected and won't be retried.
    pub dead: u32,
}

// ── TrackerInfo ────────────────────────────────────────────────────────────────

/// Last-known announce result from a single tracker.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrackerInfo {
    /// Full tracker URL, e.g. `udp://tracker.opentrackr.org:1337/announce`.
    pub url: String,
    /// Number of peers returned in the last announce response.
    pub peers_returned: u32,
    /// Unix epoch ms of the last successful announce, or `None`.
    pub last_announce_ms: Option<i64>,
    /// Human-readable error from the last failed announce, or `None`.
    pub last_error: Option<String>,
}
