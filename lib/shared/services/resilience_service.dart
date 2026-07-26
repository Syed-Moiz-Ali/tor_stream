import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../bridge/bridge.dart';
import '../torrent_box.dart';
import '../../features/home/providers/torrent_list_provider.dart' show streamOnlyTorrentIdsProvider;

class ResilienceService {
  final Ref ref;
  Timer? _heartbeatTimer;
  Timer? _stallTimer;
  StreamSubscription? _connectivitySubscription;
  bool _engineHealthy = true;
  bool _wasPreviouslyConnected = true;

  ResilienceService(this.ref);

  void start() {
    _startHeartbeat();
    _startStallDetection();
    _monitorConnectivity();
  }

  void stop() {
    _heartbeatTimer?.cancel();
    _stallTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final ok = ping();
        if (!_engineHealthy && ok) {
          _engineHealthy = true;
        }
        _engineHealthy = ok;
      } catch (_) {
        if (_engineHealthy) {
          _engineHealthy = false;
          _onEngineLost();
        }
      }
    });
  }

  void _startStallDetection() {
    _stallTimer?.cancel();
    _stallTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final torrents = await getAllTorrents();
        for (final t in torrents) {
          if (t.status == FrbTorrentStatus.downloading && t.numPeers == 0) {
            // Torrent has been downloading with no peers — surfaced via UI state
          }
        }
      } catch (_) {}
    });
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);

      if (connected && !_wasPreviouslyConnected) {
        _onNetworkRestored();
      }
      _wasPreviouslyConnected = connected;
    });
  }

  Future<void> _onEngineLost() async {
    try {
      await shutdownTorrentEngine();
      final dir = await _getStoragePath();
      await initializeTorrentEngine(config: FrbEngineConfig(
        downloadDir: dir,
        dataDir: dir,
        listenPort: 6881,
        maxConnections: 200,
        uploadRateLimit: 0,
        downloadRateLimit: 0,
        dhtEnabled: true,
        lsdEnabled: true,
        upnpEnabled: true,
        natpmpEnabled: true,
        anonymousMode: false,
        cacheSizeMb: 1024,
      ));

      await _replayActiveTorrents();
      _engineHealthy = true;
    } catch (_) {}
  }

  Future<void> _onNetworkRestored() async {
    if (!_engineHealthy) {
      await _onEngineLost();
    }
  }

  Future<void> _replayActiveTorrents() async {
    try {
      final stored = TorrentBox.instance.getAll();
      for (final model in stored) {
        try {
          final id = await addMagnet(magnetUri: model.magnetUri);
          ref.read(streamOnlyTorrentIdsProvider.notifier).update((set) => {...set, id});
        } catch (_) {}
      }

      final previousIds = await restoreResumeData();
      for (final id in previousIds) {
        try {
          await resumeTorrent(id: id);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<String> _getStoragePath() async {
    final dir = await path_provider.getApplicationDocumentsDirectory();
    return dir.path;
  }
}

final resilienceServiceProvider = Provider<ResilienceService>((ref) {
  final service = ResilienceService(ref);
  ref.onDispose(() => service.stop());
  return service;
});
