//! Memory optimization, object pooling, and buffer recycling.

use std::sync::Arc;
use tokio::sync::Mutex;
use bytes::BytesMut;

/// High-performance Object Pool for reusable piece byte buffers.
#[derive(Clone)]
pub struct BufferPool {
    buffer_size: usize,
    capacity: usize,
    pool: Arc<Mutex<Vec<BytesMut>>>,
}

impl BufferPool {
    pub fn new(buffer_size: usize, capacity: usize) -> Self {
        let mut pool = Vec::with_capacity(capacity);
        for _ in 0..capacity {
            pool.push(BytesMut::with_capacity(buffer_size));
        }

        Self {
            buffer_size,
            capacity,
            pool: Arc::new(Mutex::new(pool)),
        }
    }

    /// Acquire a clean buffer slice from the pool without memory allocations.
    pub async fn acquire(&self) -> BytesMut {
        let mut guard = self.pool.lock().await;
        if let Some(mut buf) = guard.pop() {
            buf.clear();
            buf
        } else {
            BytesMut::with_capacity(self.buffer_size)
        }
    }

    /// Return a buffer to the pool for reuse.
    pub async fn release(&self, mut buf: BytesMut) {
        let mut guard = self.pool.lock().await;
        if guard.len() < self.capacity {
            buf.clear();
            guard.push(buf);
        }
    }
}
