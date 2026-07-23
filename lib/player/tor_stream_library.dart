import '../bridge/bridge.dart' as bridge;

/// Flutter wrapper for Phase 8 Download Manager & Media Library APIs.
class TorStreamLibrary {
  /// Start a download task.
  static Future<BigInt?> startDownloadTask({
    required BigInt torrentId,
    required String title,
    required String savePath,
    required int totalBytes,
  }) async {
    try {
      final id = await bridge.startDownload(
        torrentId: torrentId,
        title: title,
        savePath: savePath,
        totalBytes: totalBytes,
      );
      return id;
    } catch (_) {
      return null;
    }
  }

  /// Pause a download task.
  static Future<void> pauseDownloadTask(BigInt id) async {
    try {
      await bridge.pauseDownload(id: id);
    } catch (_) {}
  }

  /// Resume a download task.
  static Future<void> resumeDownloadTask(BigInt id) async {
    try {
      await bridge.resumeDownload(id: id);
    } catch (_) {}
  }

  /// Cancel a download task.
  static Future<void> cancelDownloadTask(BigInt id) async {
    try {
      await bridge.cancelDownload(id: id);
    } catch (_) {}
  }

  /// Query full media library.
  static Future<List<bridge.FrbLibraryItem>> getMediaLibrary() async {
    try {
      return await bridge.getLibrary();
    } catch (_) {
      return [];
    }
  }

  /// Search media library by title or tag.
  static Future<List<bridge.FrbLibraryItem>> searchMediaLibrary(String query) async {
    try {
      return await bridge.searchLibrary(query: query);
    } catch (_) {
      return [];
    }
  }

  /// Query continue watching items.
  static Future<List<bridge.FrbContinueWatchingItem>> getContinueWatchingItems() async {
    try {
      return await bridge.getContinueWatching();
    } catch (_) {
      return [];
    }
  }

  /// Add item to favorites.
  static Future<void> addFavoriteItem(BigInt torrentId) async {
    try {
      await bridge.addFavorite(torrentId: torrentId);
    } catch (_) {}
  }

  /// Remove item from favorites.
  static Future<void> removeFavoriteItem(BigInt torrentId) async {
    try {
      await bridge.removeFavorite(torrentId: torrentId);
    } catch (_) {}
  }

  /// Update bandwidth limits.
  static Future<void> setBandwidthLimitConfig({
    required int downloadLimitBps,
    required int uploadLimitBps,
    required bool wifiOnly,
  }) async {
    try {
      await bridge.setBandwidthLimit(
        downloadLimitBps: downloadLimitBps,
        uploadLimitBps: uploadLimitBps,
        wifiOnly: wifiOnly,
      );
    } catch (_) {}
  }
}
