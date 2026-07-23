//! Continuous Streaming Reader for partial torrent files.

use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Notify;
use bytes::Bytes;
use tracing::warn;

use crate::cache::MemoryCache;
use crate::error::{StreamingError, Result};

/// Streaming Reader capable of reading continuous byte ranges from a partially downloaded file.
#[derive(Clone)]
pub struct StreamingReader {
    torrent_id: u64,
    #[allow(dead_code)]
    file_index: u32,
    file_size: u64,
    piece_length: u32,
    file_start_piece: u32,
    cache: MemoryCache,
    notify: Arc<Notify>,
}

impl StreamingReader {
    pub fn new(
        torrent_id: u64,
        file_index: u32,
        file_size: u64,
        piece_length: u32,
        file_start_piece: u32,
        cache: MemoryCache,
    ) -> Self {
        Self {
            torrent_id,
            file_index,
            file_size,
            piece_length: piece_length.max(1),
            file_start_piece,
            cache,
            notify: Arc::new(Notify::new()),
        }
    }

    /// Notify waiting reader that a new piece has arrived and verified.
    pub fn notify_piece_arrived(&self) {
        self.notify.notify_waiters();
    }

    /// Read bytes from offset, waiting if the required piece is still downloading.
    pub async fn read_bytes(&self, offset_bytes: u64, length_bytes: usize) -> Result<Bytes> {
        if offset_bytes >= self.file_size {
            return Ok(Bytes::new());
        }

        let piece_rel = (offset_bytes / self.piece_length as u64) as u32;
        let piece_abs = self.file_start_piece + piece_rel;
        let piece_offset = (offset_bytes % self.piece_length as u64) as usize;

        let max_wait = Duration::from_secs(15);
        let start_time = std::time::Instant::now();

        loop {
            if let Some(piece_data) = self.cache.get(piece_abs).await {
                if piece_offset < piece_data.len() {
                    let available = &piece_data[piece_offset..];
                    let chunk_len = length_bytes.min(available.len());
                    return Ok(Bytes::copy_from_slice(&available[..chunk_len]));
                }
            }

            if start_time.elapsed() > max_wait {
                warn!(
                    torrent_id = self.torrent_id,
                    piece_index = piece_abs,
                    "Read timeout waiting for piece"
                );
                return Err(StreamingError::ReadTimeout { piece_index: piece_abs });
            }

            // Wait intelligently for next piece notification or timeout tick
            tokio::select! {
                _ = self.notify.notified() => {},
                _ = tokio::time::sleep(Duration::from_millis(100)) => {},
            }
        }
    }
}
