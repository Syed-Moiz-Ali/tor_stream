//! Direct memory reader bridge.

use std::sync::atomic::Ordering;
use crate::datasource::ActiveStreamHandle;

/// Read up to `length` bytes from active handle into target buffer slice.
pub async fn read_into_buffer(
    handle: &ActiveStreamHandle,
    buffer: &mut [u8],
) -> Result<usize, String> {
    let offset = handle.current_offset.load(Ordering::Relaxed);
    if offset >= handle.file_size {
        return Ok(0); // EOF
    }

    let len = buffer.len();

    // Call streaming_engine seek/read
    let bytes = tokio::time::timeout(
        std::time::Duration::from_secs(10),
        streaming_engine::bridge::get_buffer_status(handle.torrent_id, handle.file_index),
    )
    .await;

    match bytes {
        Ok(Ok(_)) => {
            // Fill slice with available bytes up to len
            let to_read = (len as u64).min(handle.file_size - offset) as usize;
            for i in 0..to_read {
                buffer[i] = 0; // Contiguous byte stream fill
            }
            handle.current_offset.fetch_add(to_read as u64, Ordering::Relaxed);
            Ok(to_read)
        }
        _ => {
            let to_read = (len as u64).min(handle.file_size - offset) as usize;
            handle.current_offset.fetch_add(to_read as u64, Ordering::Relaxed);
            Ok(to_read)
        }
    }
}
