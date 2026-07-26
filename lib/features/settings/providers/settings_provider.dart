import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bridge/bridge.dart';

final healthStatusProvider = FutureProvider<FrbHealthStatus?>((ref) async {
  try {
    return healthStatus();
  } catch (_) {
    return null;
  }
});

final storageReportProvider = FutureProvider<FrbStorageReport?>((ref) async {
  try {
    return verifyStorage();
  } catch (_) {
    return null;
  }
});

final engineShutdownProvider = FutureProvider<void>((ref) async {
  await shutdownTorrentEngine();
});

final storageCapProvider = StateProvider<double>((ref) {
  // Returns the max storage cap in GB
  return 10.0;
});

final deleteAfterWatchingProvider = StateProvider<bool>((ref) {
  return false;
});

final autoEvictEnabledProvider = StateProvider<bool>((ref) {
  return true;
});

final settingsProvider = FutureProvider<SettingsState>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsState(
    storageCapGb: prefs.getDouble('storage_cap_gb') ?? 10.0,
    deleteAfterWatching: prefs.getBool('delete_after_watching') ?? false,
    autoEvictEnabled: prefs.getBool('auto_evict_enabled') ?? true,
    darkMode: prefs.getBool('dark_mode') ?? true,
    resumeAfterReboot: prefs.getBool('resume_after_reboot') ?? false,
  );
});

class SettingsState {
  final double storageCapGb;
  final bool deleteAfterWatching;
  final bool autoEvictEnabled;
  final bool darkMode;
  final bool resumeAfterReboot;

  const SettingsState({
    required this.storageCapGb,
    required this.deleteAfterWatching,
    required this.autoEvictEnabled,
    required this.darkMode,
    required this.resumeAfterReboot,
  });

  SettingsState copyWith({
    double? storageCapGb,
    bool? deleteAfterWatching,
    bool? autoEvictEnabled,
    bool? darkMode,
    bool? resumeAfterReboot,
  }) {
    return SettingsState(
      storageCapGb: storageCapGb ?? this.storageCapGb,
      deleteAfterWatching: deleteAfterWatching ?? this.deleteAfterWatching,
      autoEvictEnabled: autoEvictEnabled ?? this.autoEvictEnabled,
      darkMode: darkMode ?? this.darkMode,
      resumeAfterReboot: resumeAfterReboot ?? this.resumeAfterReboot,
    );
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('storage_cap_gb', storageCapGb);
    await prefs.setBool('delete_after_watching', deleteAfterWatching);
    await prefs.setBool('auto_evict_enabled', autoEvictEnabled);
    await prefs.setBool('dark_mode', darkMode);
    await prefs.setBool('resume_after_reboot', resumeAfterReboot);
  }
}
