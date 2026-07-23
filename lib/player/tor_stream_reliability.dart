import '../bridge/bridge.dart';

/// Flutter wrapper for Phase 7 Reliability, Persistence & Recovery Engine APIs.
class TorStreamReliability {
  /// Restore the latest session snapshot.
  static Future<FrbSessionSnapshot?> restoreSession() async {
    try {
      return restoreSession();
    } catch (_) {
      return null;
    }
  }

  /// Save session snapshot.
  static Future<void> saveSession(FrbSessionSnapshot snapshot) async {
    try {
      saveSession(snapshot);
    } catch (_) {}
  }

  /// Verify storage & database integrity.
  static Future<FrbStorageReport?> verifyStorage() async {
    try {
      return verifyStorage();
    } catch (_) {
      return null;
    }
  }

  /// Repair cache files.
  static Future<FrbStorageReport?> repairCache() async {
    try {
      return repairCache();
    } catch (_) {
      return null;
    }
  }

  /// Query system health status.
  static Future<FrbHealthStatus?> healthStatus() async {
    try {
      return healthStatus();
    } catch (_) {
      return null;
    }
  }

  /// Trigger immediate database auto-backup.
  static Future<String?> backupNow() async {
    try {
      return backupNow();
    } catch (_) {
      return null;
    }
  }
}
