//! Public Rust API for performance engine.

use std::sync::OnceLock;
use crate::benchmark::run_media_benchmarks;
use crate::metrics::PerformanceMetricsCollector;
use crate::models::{BenchmarkSuiteResult, PerformanceMetrics, ProfilerMetrics};
use crate::profiler::InternalProfiler;

static METRICS: OnceLock<PerformanceMetricsCollector> = OnceLock::new();
static PROFILER: OnceLock<InternalProfiler> = OnceLock::new();

fn get_metrics_collector() -> &'static PerformanceMetricsCollector {
    METRICS.get_or_init(PerformanceMetricsCollector::new)
}

fn get_profiler_instance() -> &'static InternalProfiler {
    PROFILER.get_or_init(InternalProfiler::new)
}

/// Retrieve current performance metrics.
pub async fn get_performance_metrics() -> anyhow::Result<PerformanceMetrics> {
    Ok(get_metrics_collector().get().await)
}

/// Run media profile benchmark suite.
pub fn get_benchmark_results() -> anyhow::Result<BenchmarkSuiteResult> {
    Ok(run_media_benchmarks())
}

/// Reset internal profiler timers.
pub async fn reset_profiler() -> anyhow::Result<()> {
    get_profiler_instance().reset().await;
    Ok(())
}

/// Export current profiler metrics.
pub async fn export_metrics() -> anyhow::Result<ProfilerMetrics> {
    Ok(get_profiler_instance().get_metrics().await)
}
