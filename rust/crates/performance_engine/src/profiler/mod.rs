//! Internal performance profiler measuring latencies and overheads.

use std::sync::Arc;
use tokio::sync::RwLock;

use crate::models::ProfilerMetrics;

/// Internal profiler measuring subsystem latencies.
#[derive(Clone, Default)]
pub struct InternalProfiler {
    data: Arc<RwLock<InternalProfilerData>>,
}

#[derive(Default)]
struct InternalProfilerData {
    scheduler_latency_us: u64,
    disk_read_latency_us: u64,
    read_stream_latency_us: u64,
    jni_overhead_us: u64,
    cache_hits: u64,
    cache_misses: u64,
    stalls: u32,
}

impl InternalProfiler {
    pub fn new() -> Self {
        Self::default()
    }

    pub async fn record_scheduler_latency(&self, us: u64) {
        self.data.write().await.scheduler_latency_us = us;
    }

    pub async fn record_disk_read_latency(&self, us: u64) {
        self.data.write().await.disk_read_latency_us = us;
    }

    pub async fn record_jni_overhead(&self, us: u64) {
        self.data.write().await.jni_overhead_us = us;
    }

    pub async fn reset(&self) {
        *self.data.write().await = InternalProfilerData::default();
    }

    pub async fn get_metrics(&self) -> ProfilerMetrics {
        let guard = self.data.read().await;
        let total = guard.cache_hits + guard.cache_misses;
        let eff = if total > 0 {
            (guard.cache_hits as f32 / total as f32) * 100.0
        } else {
            100.0
        };

        ProfilerMetrics {
            scheduler_latency_us: guard.scheduler_latency_us,
            disk_read_latency_us: guard.disk_read_latency_us,
            read_stream_latency_us: guard.read_stream_latency_us,
            jni_overhead_us: guard.jni_overhead_us,
            cache_efficiency_pct: eff,
            buffer_stalls_count: guard.stalls,
        }
    }
}
