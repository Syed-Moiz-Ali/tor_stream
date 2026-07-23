//! Statistics bridge for JNI.

use streaming_engine::models::StreamStatistics;

pub async fn get_statistics(torrent_id: u64, file_index: u32) -> Option<StreamStatistics> {
    streaming_engine::bridge::get_stream_statistics(torrent_id, file_index)
        .await
        .ok()
}
