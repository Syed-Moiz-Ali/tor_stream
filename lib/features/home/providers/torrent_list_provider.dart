import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/providers/rust_bridge_provider.dart';
import '../../../shared/models/torrent_state.dart';

final torrentListProvider = FutureProvider<List<TorrentState>>((ref) async {
  await ref.watch(rustBridgeInitProvider.future);
  final infos = await getAllTorrents();
  return infos.map((info) => TorrentState.fromFrb(info)).toList();
});

final torrentStatusProvider = FutureProvider.family<TorrentState, BigInt>((ref, id) async {
  final info = await getTorrentStatus(id: id);
  return TorrentState.fromFrb(info);
});

final addMagnetProvider = FutureProvider.family<void, String>((ref, magnetUri) async {
  await addMagnet(magnetUri: magnetUri);
  ref.invalidate(torrentListProvider);
});

final removeTorrentProvider = FutureProvider.family<void, ({BigInt id, bool deleteFiles})>((ref, params) async {
  await removeTorrent(id: params.id, deleteFiles: params.deleteFiles);
  ref.invalidate(torrentListProvider);
});

final pauseTorrentProvider = FutureProvider.family<void, BigInt>((ref, id) async {
  await pauseTorrent(id: id);
  ref.invalidate(torrentStatusProvider(id));
  ref.invalidate(torrentListProvider);
});

final resumeTorrentProvider = FutureProvider.family<void, BigInt>((ref, id) async {
  await resumeTorrent(id: id);
  ref.invalidate(torrentStatusProvider(id));
  ref.invalidate(torrentListProvider);
});
