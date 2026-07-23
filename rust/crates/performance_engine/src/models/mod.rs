//! Domain models for performance engine.

use serde::{Deserialize, Serialize};

/// Comprehensive real-time performance metrics snapshot.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PerformanceMetrics {
    pub startup_time_ms: u64,
    pub seek_time_ms: u64,
    pub buffer_recovery_time_ms: u64,
    pub cache_hit_rate: f32,
    pub active_peer_count: u32,
    pub avg_download_speed_bps: u64,
    pub avg_upload_speed_bps: u64,
    pub estimated_cpu_usage_pct: f32,
    pub allocated_memory_mb: u32,
    pub disk_throughput_mbps: f32,
}

/// Profiler timing measurements.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProfilerMetrics {
    pub scheduler_latency_us: u64,
    pub disk_read_latency_us: u64,
    pub read_stream_latency_us: u64,
    pub jni_overhead_us: u64,
    pub cache_efficiency_pct: f32,
    pub buffer_stalls_count: u32,
}

/// Benchmark result for media profiles.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkProfileResult {
    pub profile_name: String,
    pub file_format: String,
    pub resolution: String,
    pub bitrate_bps: u64,
    pub startup_latency_ms: u64,
    pub seek_latency_ms: u64,
    pub memory_used_mb: u32,
    pub is_smooth: bool,
}

/// Aggregated benchmark suite report.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkSuiteResult {
    pub total_profiles_tested: usize,
    pub passed_profiles: usize,
    pub average_startup_ms: u64,
    pub average_seek_ms: u64,
    pub max_memory_mb: u32,
    pub profiles: Vec<BenchmarkProfileResult>,
}
