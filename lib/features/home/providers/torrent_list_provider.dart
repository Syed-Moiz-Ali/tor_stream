import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/providers/rust_bridge_provider.dart';
import '../../../shared/models/torrent_state.dart';

final torrentEventsStreamProvider = StreamProvider<FrbEngineEvent>((ref) async* {
  await ref.watch(rustBridgeInitProvider.future);
  yield* subscribeTorrentEvents();
});

class TorrentListNotifier extends StateNotifier<AsyncValue<List<TorrentState>>> {
  TorrentListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  StreamSubscription<FrbEngineEvent>? _subscription;

  Future<void> _init() async {
    try {
      await ref.read(rustBridgeInitProvider.future);
    } catch (_) {}

    await refresh();

    try {
      _subscription = subscribeTorrentEvents().listen((event) {
        event.when(
          sessionStarted: () => refresh(),
          sessionStopped: () => refresh(),
          torrentAdded: (id, name, totalBytes) => refresh(),
          metadataReceived: (id, name, totalBytes) => refresh(),
          torrentRemoved: (id) => refresh(),
          downloadStarted: (id) => refresh(),
          downloadPaused: (id) => refresh(),
          downloadFinished: (id) => refresh(),
          progressUpdate: (id, info) {
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

  Future<void> refresh() async {
    try {
      final infos = await getAllTorrents();
      state = AsyncValue.data(infos.map((info) => TorrentState.fromFrb(info)).toList());
    } catch (_) {
      state = AsyncValue.data(state.value ?? const []);
    }
  }

  @override
  void dispose() {
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

