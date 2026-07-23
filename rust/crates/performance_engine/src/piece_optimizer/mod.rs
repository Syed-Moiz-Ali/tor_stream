//! Seek prediction and piece priority optimizer.

use std::collections::VecDeque;
use std::sync::Arc;
use tokio::sync::Mutex;

/// Predicts upcoming user seek operations based on playback velocity & seek history.
#[derive(Clone)]
pub struct SeekPredictor {
    history: Arc<Mutex<VecDeque<u64>>>,
}

impl SeekPredictor {
    pub fn new() -> Self {
        Self {
            history: Arc::new(Mutex::new(VecDeque::with_capacity(10))),
        }
    }

    /// Record a seek destination offset.
    pub async fn record_seek(&self, offset_bytes: u64) {
        let mut guard = self.history.lock().await;
        if guard.len() >= 10 {
            guard.pop_front();
        }
        guard.push_back(offset_bytes);
    }

    /// Predict next likely seek region (e.g. 10 seconds ahead for fast forward or chapter skip).
    pub async fn predict_next_target(&self, current_offset: u64, piece_length: u32) -> Option<u32> {
        let guard = self.history.lock().await;
        if guard.len() < 2 {
            return None;
        }

        // Calculate average seek jump delta
        let mut deltas = 0i64;
        for i in 1..guard.len() {
            deltas += (guard[i] as i64) - (guard[i - 1] as i64);
        }
        let avg_delta = deltas / (guard.len() as i64 - 1);

        if avg_delta > 0 {
            let predicted_offset = (current_offset as i64 + avg_delta).max(0) as u64;
            Some((predicted_offset / piece_length as u64) as u32)
        } else {
            None
        }
    }
}

impl Default for SeekPredictor {
    fn default() -> Self {
        Self::new()
    }
}
