//! Piece Scheduler module.

use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::debug;

use crate::models::PiecePriority;
use crate::prioritizer::{PiecePriorityAssignment, PiecePrioritizer};

/// Piece Scheduler orchestrates piece priority updates for a stream.
#[derive(Clone)]
pub struct PieceScheduler {
    torrent_id: u64,
    file_index: u32,
    prioritizer: Arc<PiecePrioritizer>,
    active_assignments: Arc<Mutex<Vec<PiecePriorityAssignment>>>,
}

impl PieceScheduler {
    pub fn new(
        torrent_id: u64,
        file_index: u32,
        piece_length: u32,
        total_pieces: u32,
        file_start_piece: u32,
        file_num_pieces: u32,
    ) -> Self {
        let prioritizer = Arc::new(PiecePrioritizer::new(
            piece_length,
            total_pieces,
            file_start_piece,
            file_num_pieces,
        ));

        Self {
            torrent_id,
            file_index,
            prioritizer,
            active_assignments: Arc::new(Mutex::new(Vec::new())),
        }
    }

    /// Recalculate priorities based on new read offset.
    pub async fn update_playback_position(&self, offset_bytes: u64) -> Vec<PiecePriorityAssignment> {
        let assignments = self.prioritizer.compute_priorities(offset_bytes);
        let mut guard = self.active_assignments.lock().await;

        let urgent_count = assignments.iter().filter(|a| a.priority == PiecePriority::PlaybackUrgent).count();
        debug!(
            torrent_id = self.torrent_id,
            file_index = self.file_index,
            offset_bytes,
            urgent_pieces = urgent_count,
            "Piece priorities recalculated"
        );

        *guard = assignments.clone();
        assignments
    }

    /// Get active assignments.
    pub async fn current_assignments(&self) -> Vec<PiecePriorityAssignment> {
        self.active_assignments.lock().await.clone()
    }
}
