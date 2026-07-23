//! Public Rust API for the Adaptive Streaming Engine.

use std::sync::Arc;
use dashmap::DashMap;
use once_cell::sync::Lazy;
use anyhow::Context;

use crate::models::{BufferStatus, CacheStatus, StreamStatistics};
use crate::pipeline::StreamingPipeline;

static PIPELINES: Lazy<DashMap<(u64, u32), Arc<StreamingPipeline>>> = Lazy::new(DashMap::new);

fn get_pipeline(torrent_id: u64, file_index: u32) -> anyhow::Result<Arc<StreamingPipeline>> {
    PIPELINES
        .get(&(torrent_id, file_index))
        .map(|r| Arc::clone(r.value()))
        .ok_or_else(|| anyhow::anyhow!("Stream not active for torrent_id={}, file_index={}", torrent_id, file_index))
}

/// Prepare a stream session for a torrent file.
pub async fn prepare_stream(
    torrent_id: u64,
    file_index: u32,
    file_size: u64,
    piece_length: u32,
    total_pieces: u32,
    file_start_piece: u32,
    file_num_pieces: u32,
) -> anyhow::Result<()> {
    let bus = torrent_engine::EventBus::new();
    let pipeline = Arc::new(StreamingPipeline::new(
        torrent_id,
        file_index,
        file_size,
        piece_length,
        total_pieces,
        file_start_piece,
        file_num_pieces,
        64 * 1024 * 1024, // 64MB memory cache
        bus,
    ));

    pipeline.prepare().await.context("Failed to prepare stream")?;
    PIPELINES.insert((torrent_id, file_index), pipeline);
    Ok(())
}

/// Start playback of a prepared stream.
pub async fn start_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    get_pipeline(torrent_id, file_index)?.start().await.context("Failed to start stream")
}

/// Pause stream playback.
pub async fn pause_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    get_pipeline(torrent_id, file_index)?.pause().await.context("Failed to pause stream")
}

/// Resume stream playback.
pub async fn resume_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    get_pipeline(torrent_id, file_index)?.resume().await.context("Failed to resume stream")
}

/// Seek stream to offset bytes.
pub async fn seek_stream(torrent_id: u64, file_index: u32, offset_bytes: u64) -> anyhow::Result<()> {
    get_pipeline(torrent_id, file_index)?.seek(offset_bytes).await.context("Failed to seek stream")
}

/// Stop stream session.
pub async fn stop_stream(torrent_id: u64, file_index: u32) -> anyhow::Result<()> {
    if let Some((_, pipeline)) = PIPELINES.remove(&(torrent_id, file_index)) {
        pipeline.stop().await.context("Failed to stop stream")?;
    }
    Ok(())
}

/// Query current buffer status.
pub async fn get_buffer_status(torrent_id: u64, file_index: u32) -> anyhow::Result<BufferStatus> {
    Ok(get_pipeline(torrent_id, file_index)?.get_buffer_status().await)
}

/// Query global cache status.
pub async fn get_cache_status(torrent_id: u64, file_index: u32) -> anyhow::Result<CacheStatus> {
    Ok(get_pipeline(torrent_id, file_index)?.get_cache_status().await)
}

/// Query real-time stream statistics.
pub async fn get_stream_statistics(torrent_id: u64, file_index: u32) -> anyhow::Result<StreamStatistics> {
    Ok(get_pipeline(torrent_id, file_index)?.get_statistics().await)
}
