//! Memory and Disk Caching for streaming pieces.

use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use tokio::sync::Mutex;
use bytes::Bytes;
use tracing::debug;

use crate::models::CacheStatus;

/// In-memory LRU Piece Cache with pinned piece support.
#[derive(Clone)]
pub struct MemoryCache {
    capacity_bytes: u64,
    inner: Arc<Mutex<MemoryCacheInner>>,
}

struct MemoryCacheInner {
    used_bytes: u64,
    cache: HashMap<u32, Bytes>,
    lru_order: Vec<u32>,
    pinned: HashSet<u32>,
    hits: u64,
    misses: u64,
}

impl MemoryCache {
    pub fn new(capacity_bytes: u64) -> Self {
        Self {
            capacity_bytes,
            inner: Arc::new(Mutex::new(MemoryCacheInner {
                used_bytes: 0,
                cache: HashMap::new(),
                lru_order: Vec::new(),
                pinned: HashSet::new(),
                hits: 0,
                misses: 0,
            })),
        }
    }

    /// Get piece from memory cache.
    pub async fn get(&self, piece_index: u32) -> Option<Bytes> {
        let mut guard = self.inner.lock().await;
        if let Some(data) = guard.cache.get(&piece_index).cloned() {
            guard.hits += 1;
            // Move to back of LRU order
            guard.lru_order.retain(|&idx| idx != piece_index);
            guard.lru_order.push(piece_index);
            Some(data)
        } else {
            guard.misses += 1;
            None
        }
    }

    /// Put piece data into cache. Evicts unpinned items if capacity exceeded.
    pub async fn put(&self, piece_index: u32, data: Bytes, pinned: bool) {
        let size = data.len() as u64;
        let mut guard = self.inner.lock().await;

        if pinned {
            guard.pinned.insert(piece_index);
        }

        // Evict if over capacity
        while guard.used_bytes + size > self.capacity_bytes && !guard.lru_order.is_empty() {
            let candidate = guard.lru_order.first().copied();
            if let Some(cand_idx) = candidate {
                if guard.pinned.contains(&cand_idx) {
                    // Skip pinned candidate for now
                    let item = guard.lru_order.remove(0);
                    guard.lru_order.push(item);
                    continue;
                }
                guard.lru_order.remove(0);
                if let Some(removed) = guard.cache.remove(&cand_idx) {
                    guard.used_bytes = guard.used_bytes.saturating_sub(removed.len() as u64);
                    debug!(piece_index = cand_idx, "Evicted piece from memory cache");
                }
            } else {
                break;
            }
        }

        guard.used_bytes += size;
        guard.cache.insert(piece_index, data);
        guard.lru_order.retain(|&idx| idx != piece_index);
        guard.lru_order.push(piece_index);
    }

    /// Pin a piece index so it won't be evicted.
    pub async fn pin(&self, piece_index: u32) {
        self.inner.lock().await.pinned.insert(piece_index);
    }

    /// Unpin a piece index.
    pub async fn unpin(&self, piece_index: u32) {
        self.inner.lock().await.pinned.remove(&piece_index);
    }

    /// Get cache status metrics.
    pub async fn status(&self) -> CacheStatus {
        let guard = self.inner.lock().await;
        let total_ops = guard.hits + guard.misses;
        let hit_ratio = if total_ops > 0 {
            guard.hits as f32 / total_ops as f32
        } else {
            0.0
        };

        CacheStatus {
            memory_used_bytes: guard.used_bytes,
            memory_capacity_bytes: self.capacity_bytes,
            pinned_pieces_count: guard.pinned.len(),
            disk_used_bytes: 0,
            cache_hit_count: guard.hits,
            cache_miss_count: guard.misses,
            hit_ratio,
        }
    }
}
