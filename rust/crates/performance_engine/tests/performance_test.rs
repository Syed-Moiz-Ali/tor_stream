//! Unit and integration tests for performance_engine.

use performance_engine::{
    bridge as engine,
    cache_optimizer::calculate_optimal_cache_bytes,
    memory::BufferPool,
    network_optimizer::calculate_adaptive_upload_limit,
    piece_optimizer::SeekPredictor,
};

#[tokio::test]
async fn test_buffer_pool_acquire_and_release() {
    let pool = BufferPool::new(1024, 2);

    let buf1 = pool.acquire().await;
    let buf2 = pool.acquire().await;

    assert_eq!(buf1.capacity(), 1024);
    assert_eq!(buf2.capacity(), 1024);

    pool.release(buf1).await;
    pool.release(buf2).await;
}

#[tokio::test]
async fn test_seek_predictor() {
    let predictor = SeekPredictor::new();

    predictor.record_seek(10_000_000).await;
    predictor.record_seek(20_000_000).await;
    predictor.record_seek(30_000_000).await;

    let target = predictor.predict_next_target(30_000_000, 1_000_000).await;
    assert!(target.is_some());
    assert_eq!(target.unwrap(), 40); // 40MB -> piece 40
}

#[test]
fn test_cache_auto_tuner() {
    let low_ram_cache = calculate_optimal_cache_bytes(2048, false);
    let high_ram_4k_cache = calculate_optimal_cache_bytes(8192, true);

    assert_eq!(low_ram_cache, 48 * 1024 * 1024);
    assert_eq!(high_ram_4k_cache, 128 * 1024 * 1024);
}

#[test]
fn test_adaptive_upload_limit() {
    let slow_limit = calculate_adaptive_upload_limit(500_000);
    let fast_limit = calculate_adaptive_upload_limit(10_000_000);

    assert_eq!(slow_limit, 50 * 1024);
    assert_eq!(fast_limit, 0); // unlimited
}

#[tokio::test]
async fn test_performance_metrics_bridge() {
    let metrics = engine::get_performance_metrics().await.unwrap();
    assert!(metrics.estimated_cpu_usage_pct < 5.0);

    let benchmark = engine::get_benchmark_results().unwrap();
    assert!(benchmark.passed_profiles >= 4);
    assert!(benchmark.average_startup_ms < 5000);
}
