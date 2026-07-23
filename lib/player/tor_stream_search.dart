import '../bridge/bridge.dart' as bridge;

/// Flutter wrapper for Phase 10 Search, Indexing & Content Discovery Engine APIs.
class TorStreamSearch {
  /// Perform fast full-text search.
  static Future<List<bridge.FrbSearchResultItem>> search(String query) async {
    try {
      return await bridge.search(query: query);
    } catch (_) {
      return [];
    }
  }

  /// Apply structured filters.
  static Future<List<bridge.FrbSearchResultItem>> filter({
    required List<bridge.FrbSearchResultItem> items,
    required bridge.FrbSearchFilters filters,
  }) async {
    try {
      return await bridge.filter(items: items, filters: filters);
    } catch (_) {
      return items;
    }
  }

  /// Apply sorting criteria.
  static Future<List<bridge.FrbSearchResultItem>> sort({
    required List<bridge.FrbSearchResultItem> items,
    required bridge.FrbSortOptions options,
  }) async {
    try {
      return await bridge.sort(items: items, options: options);
    } catch (_) {
      return items;
    }
  }

  /// Create a custom media collection.
  static Future<BigInt?> createCollection({
    required String name,
    required String description,
  }) async {
    try {
      final id = await bridge.createCollection(name: name, description: description);
      return id;
    } catch (_) {
      return null;
    }
  }

  /// Delete a custom media collection.
  static Future<void> deleteCollection(BigInt id) async {
    try {
      await bridge.deleteCollection(id: id);
    } catch (_) {}
  }

  /// Add torrent to collection.
  static Future<void> addToCollection({
    required BigInt collectionId,
    required BigInt torrentId,
  }) async {
    try {
      await bridge.addToCollection(collectionId: collectionId, torrentId: torrentId);
    } catch (_) {}
  }

  /// Remove torrent from collection.
  static Future<void> removeFromCollection({
    required BigInt collectionId,
    required BigInt torrentId,
  }) async {
    try {
      await bridge.removeFromCollection(collectionId: collectionId, torrentId: torrentId);
    } catch (_) {}
  }
}
