import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../bridge/bridge.dart';
import '../../../shared/providers/rust_bridge_provider.dart';
import '../../home/providers/torrent_list_provider.dart';

final addTorrentStateProvider = StateProvider<AddTorrentState>((_) => const AddTorrentState());

class AddTorrentState {
  final bool isLoading;
  final String? error;
  final bool? success;
  final BigInt? torrentId;

  const AddTorrentState({this.isLoading = false, this.error, this.success, this.torrentId});

  AddTorrentState copyWith({bool? isLoading, String? error, bool? success, BigInt? torrentId}) {
    return AddTorrentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
      torrentId: torrentId ?? this.torrentId,
    );
  }
}

final addMagnetLinkProvider = FutureProvider.family<BigInt, String>((ref, magnetUri) async {
  await ref.watch(rustBridgeInitProvider.future);
  final id = await addMagnet(magnetUri: magnetUri);
  await ref.read(torrentListNotifierProvider.notifier).refresh();
  return id;
});

final addTorrentFileProvider = FutureProvider.family<BigInt, String>((ref, filePath) async {
  await ref.watch(rustBridgeInitProvider.future);
  final file = File(filePath);
  final data = await file.readAsBytes();
  final id = await addTorrentFile(data: data);
  await ref.read(torrentListNotifierProvider.notifier).refresh();
  return id;
});

