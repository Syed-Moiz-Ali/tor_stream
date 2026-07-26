import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bridge/bridge.dart';

class ForegroundService {
  static const _channel = MethodChannel('tor_stream/foreground_service');

  static Future<bool> start() async {
    try {
      return await _channel.invokeMethod<bool>('start') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> stop() async {
    try {
      return await _channel.invokeMethod<bool>('stop') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateNotification({
    String title = 'TorStream',
    double progress = 0.0,
    String speed = '',
    int activeCount = 0,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('updateNotification', {
        'title': title,
        'progress': progress,
        'speed': speed,
        'activeCount': activeCount,
      }) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestBatteryOptimizationExemption() async {
    try {
      return await _channel.invokeMethod<bool>('requestBatteryOptimizationExemption') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? false;
    } catch (_) {
      return true;
    }
  }
}

final activeTorrentCountProvider = StateProvider<int>((ref) => 0);

final foregroundServiceProvider = Provider<ForegroundServiceNotifier>((ref) {
  return ForegroundServiceNotifier(ref);
});

class ForegroundServiceNotifier {
  final Ref ref;
  Timer? _notificationTimer;

  ForegroundServiceNotifier(this.ref);

  void startMonitoring() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateNotification();
    });
  }

  void stopMonitoring() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Future<void> _updateNotification() async {
    final activeCount = ref.read(activeTorrentCountProvider);
    if (activeCount == 0) {
      await ForegroundService.stop();
      stopMonitoring();
      return;
    }

    try {
      final torrents = await getAllTorrents();
      final active = torrents.where((t) =>
          t.status == FrbTorrentStatus.downloading ||
          t.status == FrbTorrentStatus.seeding);

      if (active.isEmpty) {
        await ForegroundService.stop();
        stopMonitoring();
        return;
      }

      final totalProgress = active.fold<double>(0, (sum, t) => sum + t.progress) / active.length;
      final totalSpeed = active.fold<int>(0, (sum, t) => sum + t.downloadRate);
      final speedLabel = _formatSpeed(totalSpeed);
      final primaryName = active.first.name ?? 'TorStream';

      await ForegroundService.updateNotification(
        title: primaryName,
        progress: totalProgress,
        speed: speedLabel,
        activeCount: active.length,
      );
    } catch (_) {}
  }

  String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '$bytesPerSec B/s';
    if (bytesPerSec < 1048576) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / 1048576).toStringAsFixed(1)} MB/s';
  }

  void dispose() {
    stopMonitoring();
  }
}
