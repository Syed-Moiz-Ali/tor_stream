import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/providers/rust_bridge_provider.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../shared/services/foreground_service.dart';

final torrentEventsStreamProvider = StreamProvider<FrbEngineEvent>((ref) async* {
  await ref.watch(rustBridgeInitProvider.future);
  yield* subscribeTorrentEvents();
});

final streamOnlyTorrentIdsProvider = StateProvider<Set<BigInt>>((ref) => {});

class TorrentListNotifier extends StateNotifier<AsyncValue<List<TorrentState>>> {
  TorrentListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  StreamSubscription<FrbEngineEvent>? _subscription;
  Timer? _timer;
  bool _refreshPending = false;

  Future<void> _init() async {
    try {
      await ref.read(rustBridgeInitProvider.future);
    } catch (_) {}

    await refresh();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => Future.microtask(() => refresh()));

    try {
      _subscription = subscribeTorrentEvents().listen((event) {
        event.when(
          sessionStarted: () => _scheduleRefresh(),
          sessionStopped: () => _scheduleRefresh(),
          torrentAdded: (id, name, totalBytes) => _scheduleRefresh(),
          metadataReceived: (id, name, totalBytes) => _scheduleRefresh(),
          torrentRemoved: (id) => _scheduleRefresh(),
          downloadStarted: (id) => _scheduleRefresh(),
          downloadPaused: (id) => _scheduleRefresh(),
          downloadFinished: (id) {
            _scheduleRefresh();
            _checkDeleteAfterWatching(id);
          },
          progressUpdate: (id, info) {
            final streamOnlyIds = ref.read(streamOnlyTorrentIdsProvider);
            if (streamOnlyIds.contains(id)) {
              state.whenData((list) {
                if (list.any((t) => t.id == id)) {
                  state = AsyncValue.data(list.where((t) => t.id != id).toList());
                }
              });
              return;
            }

            final updatedItem = TorrentState.fromFrb(info);
            state.whenData((list) {
              final index = list.indexWhere((t) => t.id == id);
              if (index != -1) {
                final newList = List<TorrentState>.from(list);
                newList[index] = updatedItem;
                state = AsyncValue.data(newList);
              } else {
                refresh();
              }
            });
          },
          peerUpdate: (id, stats) {},
          peerConnected: (id, peerAddr) {},
          peerDisconnected: (id, peerAddr, reason) {},
          resumeSaved: (id) {},
          error: (id, message, fatal) {},
        );
      }, onError: (_) {});
    } catch (_) {}
  }

  Future<void> _checkDeleteAfterWatching(BigInt id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('delete_after_watching') == true) {
        await removeTorrent(id: id, deleteFiles: true);
        _scheduleRefresh();
      }
    } catch (_) {}
  }

  /// Throttled refresh — debounces rapid event bursts.
  void _scheduleRefresh() {
    if (_refreshPending) return;
    _refreshPending = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      _refreshPending = false;
      refresh();
    });
  }

  Future<void> refresh() async {
    try {
      final infos = await getAllTorrents();
      final streamOnlyIds = ref.read(streamOnlyTorrentIdsProvider);
      final list = infos
          .where((info) => !streamOnlyIds.contains(info.id))
          .map((info) => TorrentState.fromFrb(info))
          .toList();
      state = AsyncValue.data(list);

      final activeCount = infos.where((t) =>
          t.status == FrbTorrentStatus.downloading ||
          t.status == FrbTorrentStatus.seeding).length;
      ref.read(activeTorrentCountProvider.notifier).state = activeCount;
    } catch (_) {
      state = AsyncValue.data(state.value ?? const []);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final torrentListNotifierProvider =
    StateNotifierProvider<TorrentListNotifier, AsyncValue<List<TorrentState>>>((ref) {
  return TorrentListNotifier(ref);
});

final torrentListProvider = FutureProvider<List<TorrentState>>((ref) async {
  final notifierState = ref.watch(torrentListNotifierProvider);
  return notifierState.value ?? [];
});

final torrentStatusProvider = FutureProvider.family<TorrentState, BigInt>((ref, id) async {
  final list = ref.watch(torrentListProvider).value ?? [];
  return list.firstWhere(
    (t) => t.id == id,
    orElse: () => throw Exception('Torrent not found'),
  );
});

final addMagnetProvider = FutureProvider.family<void, String>((ref, magnetUri) async {
  await addMagnet(magnetUri: magnetUri);
  ref.read(torrentListNotifierProvider.notifier).refresh();
});

final removeTorrentProvider = FutureProvider.family<void, ({BigInt id, bool deleteFiles})>((ref, params) async {
  await removeTorrent(id: params.id, deleteFiles: params.deleteFiles);
  ref.read(torrentListNotifierProvider.notifier).refresh();
});

final pauseTorrentProvider = FutureProvider.family<void, BigInt>((ref, id) async {
  await pauseTorrent(id: id);
  ref.read(torrentListNotifierProvider.notifier).refresh();
});

final resumeTorrentProvider = FutureProvider.family<void, BigInt>((ref, id) async {
  await resumeTorrent(id: id);
  ref.read(torrentListNotifierProvider.notifier).refresh();
});

