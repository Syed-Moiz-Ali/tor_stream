import '../bridge/bridge.dart';

/// Flutter wrapper for Phase 6 Performance Engine & Profiler APIs.
class TorStreamPerformance {
  /// Query real-time performance metrics.
  static Future<FrbPerformanceMetrics?> getPerformanceMetrics() async {
    try {
      return await getPerformanceMetrics();
    } catch (_) {
      return null;
    }
  }

  /// Run media profile benchmark suite.
  static Future<FrbBenchmarkSuiteResult?> getBenchmarkResults() async {
    try {
      return getBenchmarkResults();
    } catch (_) {
      return null;
    }
  }

  /// Reset internal profiler timers.
  static Future<void> resetProfiler() async {
    try {
      await resetProfiler();
    } catch (_) {}
  }

  /// Export current profiler metrics.
  static Future<FrbProfilerMetrics?> exportMetrics() async {
    try {
      return await exportMetrics();
    } catch (_) {
      return null;
    }
  }
}
