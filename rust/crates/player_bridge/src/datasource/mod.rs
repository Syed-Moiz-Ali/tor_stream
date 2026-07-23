//! Player DataSource bridge.

use std::sync::Arc;
use dashmap::DashMap;
use once_cell::sync::Lazy;

/// Open stream handle holding read position and session metadata.
#[derive(Debug)]
pub struct ActiveStreamHandle {
    pub torrent_id: u64,
    pub file_index: u32,
    pub file_size: u64,
    pub current_offset: std::sync::atomic::AtomicU64,
}

static ACTIVE_STREAMS: Lazy<DashMap<i64, Arc<ActiveStreamHandle>>> = Lazy::new(DashMap::new);
static NEXT_HANDLE_ID: std::sync::atomic::AtomicI64 = std::sync::atomic::AtomicI64::new(1);

/// Register an active stream and return an opaque handle ID for JNI.
pub fn open_handle(torrent_id: u64, file_index: u32, file_size: u64) -> i64 {
    let handle_id = NEXT_HANDLE_ID.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let handle = Arc::new(ActiveStreamHandle {
        torrent_id,
        file_index,
        file_size,
        current_offset: std::sync::atomic::AtomicU64::new(0),
    });
    ACTIVE_STREAMS.insert(handle_id, handle);
    handle_id
}

/// Retrieve an active stream handle.
pub fn get_handle(handle_id: i64) -> Option<Arc<ActiveStreamHandle>> {
    ACTIVE_STREAMS.get(&handle_id).map(|r| Arc::clone(r.value()))
}

/// Close an active stream handle.
pub fn close_handle(handle_id: i64) {
    ACTIVE_STREAMS.remove(&handle_id);
}
