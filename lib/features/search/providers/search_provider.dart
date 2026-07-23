import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/providers/rust_bridge_provider.dart';

final searchResultsProvider = FutureProvider.family<List<FrbSearchResultItem>, String>(
  (ref, query) async {
    await ref.watch(rustBridgeInitProvider.future);
    return search(query: query);
  },
);

final searchWithFiltersProvider = FutureProvider.family<List<FrbSearchResultItem>, ({
  List<FrbSearchResultItem> items,
  FrbSearchFilters filters,
})>(
  (ref, params) async {
    await ref.watch(rustBridgeInitProvider.future);
    return filter(items: params.items, filters: params.filters);
  },
);

final continueWatchingProvider = FutureProvider<List<FrbContinueWatchingItem>>((ref) async {
  await ref.watch(rustBridgeInitProvider.future);
  return getContinueWatching();
});

final libraryItemsProvider = FutureProvider<List<FrbLibraryItem>>((ref) async {
  await ref.watch(rustBridgeInitProvider.future);
  return getLibrary();
});
