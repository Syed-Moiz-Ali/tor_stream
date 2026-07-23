import '../bridge/bridge.dart' as bridge;

/// Flutter wrapper for Phase 9 Media Enhancement Engine APIs.
class TorStreamEnhancement {
  /// Load subtitle configuration.
  static Future<void> loadSubtitles(bridge.FrbSubtitleConfig config) async {
    try {
      await bridge.loadSubtitles(config: config);
    } catch (_) {}
  }

  /// Change active subtitle delay offset in milliseconds.
  static Future<int?> changeSubtitle(int delayMs) async {
    try {
      return await bridge.changeSubtitle(delayMs: delayMs);
    } catch (_) {
      return null;
    }
  }

  /// Select active audio track index.
  static Future<void> changeAudioTrack(int trackIndex) async {
    try {
      await bridge.changeAudioTrack(trackIndex: trackIndex);
    } catch (_) {}
  }

  /// Generate media timeline thumbnails.
  static Future<List<bridge.FrbMediaThumbnail>> generateThumbnails({
    required double durationSeconds,
    int intervalSeconds = 30,
  }) async {
    try {
      return await bridge.generateThumbnails(
        durationSeconds: durationSeconds,
        intervalSeconds: intervalSeconds,
      );
    } catch (_) {
      return [];
    }
  }

  /// Retrieve chapter list for media duration.
  static Future<List<bridge.FrbMediaChapter>> getChapters(double durationSeconds) async {
    try {
      return await bridge.getChapters(durationSeconds: durationSeconds);
    } catch (_) {
      return [];
    }
  }

  /// Set playback speed multiplier.
  static Future<double?> setPlaybackSpeed(double speed) async {
    try {
      return await bridge.setPlaybackSpeed(speed: speed);
    } catch (_) {
      return null;
    }
  }
}
