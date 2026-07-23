//! Event definitions for the metadata engine.

use serde::{Deserialize, Serialize};
use crate::models::{Artwork, SubtitleTrack, TorrentMedia};

/// Events published during media scanning and analysis.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum MetadataEvent {
    /// Metadata parsing has started for a torrent.
    MetadataParsingStarted { torrent_id: u64 },
    /// Torrent metadata parsed; file structure ready.
    MetadataReady { torrent_id: u64, file_count: usize },
    /// Primary or secondary media files detected.
    MediaDetected { torrent_id: u64, primary_file_name: Option<String> },
    /// External or embedded subtitle detected.
    SubtitleDetected { torrent_id: u64, subtitle: SubtitleTrack },
    /// Poster or backdrop image detected.
    ArtworkDetected { torrent_id: u64, artwork: Artwork },
    /// Full deep analysis (including ffprobe if run) completed.
    AnalysisCompleted { torrent_id: u64, media: TorrentMedia },
}
