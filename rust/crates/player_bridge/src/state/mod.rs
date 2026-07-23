//! State bridge for JNI.

use streaming_engine::models::PlaybackState;

pub async fn get_state(torrent_id: u64, file_index: u32) -> PlaybackState {
    streaming_engine::bridge::get_stream_statistics(torrent_id, file_index)
        .await
        .map(|s| s.playback_state)
        .unwrap_or(PlaybackState::Idle)
}
