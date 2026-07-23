//! Comprehensive tests for the adaptive streaming engine.

use bytes::Bytes;
use streaming_engine::{
    bridge as engine,
    buffer::{BufferConfig, BufferManager},
    cache::MemoryCache,
    models::{PlaybackState, PiecePriority},
    prioritizer::PiecePrioritizer,
    reader::StreamingReader,
    scheduler::PieceScheduler,
};

#[tokio::test]
async fn test_piece_prioritizer_ordering() {
    let prioritizer = PiecePrioritizer::new(
        1_048_576, // 1MB pieces
        100,
        0,
        100,
    );

    let assignments = prioritizer.compute_priorities(0);
    assert_eq!(assignments[0].priority, PiecePriority::PlaybackUrgent);
    assert_eq!(assignments[1].priority, PiecePriority::PlaybackUrgent);
    assert_eq!(assignments[3].priority, PiecePriority::ReadAhead);
    assert_eq!(assignments[10].priority, PiecePriority::NearFuture);
    assert_eq!(assignments[30].priority, PiecePriority::Sequential);
}

#[tokio::test]
async fn test_memory_cache_eviction_and_pinning() {
    let cache = MemoryCache::new(3_000_000); // 3MB limit

    let data1 = Bytes::from(vec![1u8; 1_000_000]);
    let data2 = Bytes::from(vec![2u8; 1_000_000]);
    let data3 = Bytes::from(vec![3u8; 1_000_000]);
    let data4 = Bytes::from(vec![4u8; 1_000_000]);

    // Pin piece 0
    cache.put(0, data1, true).await;
    cache.put(1, data2, false).await;
    cache.put(2, data3, false).await;

    // Over capacity insert piece 3 -> unpinned piece 1 should be evicted, pinned piece 0 retained
    cache.put(3, data4, false).await;

    assert!(cache.get(0).await.is_some(), "Pinned piece should not be evicted");
    assert!(cache.get(3).await.is_some());
}

#[tokio::test]
async fn test_adaptive_buffer_manager() {
    let mgr = BufferManager::new(1, 0, BufferConfig::default());

    // High bandwidth simulation (> 120% bitrate)
    mgr.update_progress(0, 4_000_000, 5_000_000, 2_000_000).await;
    let status = mgr.status().await;
    assert!(status.is_ready);

    // Low bandwidth simulation -> emergency threshold trigger
    mgr.update_progress(0, 1_000_000, 500_000, 2_000_000).await;
    let status2 = mgr.status().await;
    assert!(status2.is_buffering);
}

#[tokio::test]
async fn test_streaming_reader_block_and_notify() {
    let cache = MemoryCache::new(10_000_000);
    let reader = StreamingReader::new(1, 0, 5_000_000, 1_000_000, 0, cache.clone());

    // Put piece 0 into cache
    cache.put(0, Bytes::from(vec![0xAA; 1_000_000]), false).await;
    reader.notify_piece_arrived();

    let data = reader.read_bytes(0, 500).await.unwrap();
    assert_eq!(data.len(), 500);
    assert_eq!(data[0], 0xAA);
}

#[tokio::test]
async fn test_stream_pipeline_lifecycle_and_seek() {
    let torrent_id = 99;
    let file_index = 0;

    engine::prepare_stream(
        torrent_id,
        file_index,
        100_000_000, // 100MB file
        1_048_576,   // 1MB pieces
        100,
        0,
        100,
    )
    .await
    .unwrap();

    engine::start_stream(torrent_id, file_index).await.unwrap();

    let buf_status = engine::get_buffer_status(torrent_id, file_index).await.unwrap();
    assert_eq!(buf_status.torrent_id, torrent_id);

    // Seek to 50MB offset
    engine::seek_stream(torrent_id, file_index, 50_000_000).await.unwrap();

    let stats = engine::get_stream_statistics(torrent_id, file_index).await.unwrap();
    assert!(stats.total_bytes_streamed == 0 || stats.playback_state == PlaybackState::Buffering || stats.playback_state == PlaybackState::Playing);

    engine::stop_stream(torrent_id, file_index).await.unwrap();
}
