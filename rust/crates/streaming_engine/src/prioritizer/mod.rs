//! Seek-aware Piece Prioritizer algorithm.

use crate::models::PiecePriority;

/// Assignment of priority for a single piece index.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PiecePriorityAssignment {
    pub piece_index: u32,
    pub priority: PiecePriority,
}

/// Prioritizer engine that computes piece priorities based on current playback byte offset.
pub struct PiecePrioritizer {
    piece_length: u32,
    #[allow(dead_code)]
    total_pieces: u32,
    file_start_piece: u32,
    file_num_pieces: u32,
}

impl PiecePrioritizer {
    pub fn new(
        piece_length: u32,
        total_pieces: u32,
        file_start_piece: u32,
        file_num_pieces: u32,
    ) -> Self {
        Self {
            piece_length: piece_length.max(1),
            total_pieces,
            file_start_piece,
            file_num_pieces,
        }
    }

    /// Compute priority for all pieces in the target file based on read_offset_bytes.
    pub fn compute_priorities(&self, read_offset_bytes: u64) -> Vec<PiecePriorityAssignment> {
        let current_rel_piece = (read_offset_bytes / self.piece_length as u64) as u32;
        let current_abs_piece = self.file_start_piece + current_rel_piece;

        let mut assignments = Vec::with_capacity(self.file_num_pieces as usize);

        for rel in 0..self.file_num_pieces {
            let piece_idx = self.file_start_piece + rel;

            let priority = if piece_idx == current_abs_piece || piece_idx == current_abs_piece + 1 {
                PiecePriority::PlaybackUrgent
            } else if piece_idx > current_abs_piece && piece_idx <= current_abs_piece + 5 {
                PiecePriority::ReadAhead
            } else if piece_idx > current_abs_piece + 5 && piece_idx <= current_abs_piece + 20 {
                PiecePriority::NearFuture
            } else if piece_idx > current_abs_piece + 20 {
                PiecePriority::Sequential
            } else {
                PiecePriority::Background
            };

            assignments.push(PiecePriorityAssignment {
                piece_index: piece_idx,
                priority,
            });
        }

        assignments
    }
}
