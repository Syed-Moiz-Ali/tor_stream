import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bridge/bridge.dart';

final healthStatusProvider = FutureProvider<FrbHealthStatus?>((ref) async {
  try {
    return await healthStatus();
  } catch (_) {
    return null;
  }
});

final storageReportProvider = FutureProvider<FrbStorageReport?>((ref) async {
  try {
    return await verifyStorage();
  } catch (_) {
    return null;
  }
});

final engineShutdownProvider = FutureProvider<void>((ref) async {
  await shutdownTorrentEngine();
});
