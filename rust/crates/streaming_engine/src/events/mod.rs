//! Event definitions for adaptive streaming engine.

use serde::{Deserialize, Serialize};
use crate::models::{BufferStatus, PlaybackState};

/// Strongly typed streaming events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum StreamingEvent {
    /// Playback state transition occurred.
    StateChanged { torrent_id: u64, file_index: u32, from: PlaybackState, to: PlaybackState },
    /// Startup buffering initiated.
    BufferStarted { torrent_id: u64, file_index: u32 },
    /// Periodic buffer health update.
    BufferUpdated { torrent_id: u64, file_index: u32, status: BufferStatus },
    /// Buffer recovered after a stall/underrun.
    BufferRecovered { torrent_id: u64, file_index: u32 },
    /// User initiated a seek operation.
    SeekStarted { torrent_id: u64, file_index: u32, target_offset_bytes: u64 },
    /// Seek completed; target region buffered.
    SeekCompleted { torrent_id: u64, file_index: u32, offset_bytes: u64 },
    /// Piece data retrieved from cache.
    CacheHit { piece_index: u32 },
    /// Piece data required disk/network fetch.
    CacheMiss { piece_index: u32 },
    /// Priority updated for a piece range.
    PiecePrioritized { piece_start: u32, piece_end: u32, priority_level: u8 },
    /// Stream is sufficiently buffered for smooth playback start.
    PlaybackReady { torrent_id: u64, file_index: u32 },
    /// Playback stalled due to buffer underrun.
    PlaybackStalled { torrent_id: u64, file_index: u32 },
}
