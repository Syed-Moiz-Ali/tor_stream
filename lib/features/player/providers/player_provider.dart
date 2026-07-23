import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/models/playback_state.dart';

class StreamState {
  final bool isInitialized;
  final String? streamUrl;
  final String? fileName;
  final PlaybackState? playback;
  final String? error;

  const StreamState({
    this.isInitialized = false,
    this.streamUrl,
    this.fileName,
    this.playback,
    this.error,
  });

  StreamState copyWith({
    bool? isInitialized,
    String? streamUrl,
    String? fileName,
    PlaybackState? playback,
    String? error,
  }) {
    return StreamState(
      isInitialized: isInitialized ?? this.isInitialized,
      streamUrl: streamUrl ?? this.streamUrl,
      fileName: fileName ?? this.fileName,
      playback: playback ?? this.playback,
      error: error,
    );
  }
}

class PlayerNotifier extends StateNotifier<StreamState> {
  final BigInt torrentId;
  final int fileIndex;
  Timer? _positionTimer;
  bool _disposed = false;

  PlayerNotifier(this.torrentId, this.fileIndex) : super(const StreamState());

  Future<void> init() async {
    try {
      try {
        await resumeTorrent(id: torrentId);
      } catch (_) {}
      if (_disposed) return;
      await startStream(torrentId: torrentId, fileIndex: fileIndex);
      if (_disposed) return;
      final url = await getStreamUrl(torrentId: torrentId, fileIndex: fileIndex);
      if (_disposed) return;
      final buf = await getBufferStatus(torrentId: torrentId, fileIndex: fileIndex);
      if (_disposed) return;
      final stats = await getStreamStatistics(torrentId: torrentId, fileIndex: fileIndex);
      if (_disposed) return;
      final torrentInfo = await getTorrentStatus(id: torrentId);
      if (_disposed) return;
      state = state.copyWith(
        isInitialized: true,
        streamUrl: url,
        fileName: torrentInfo.name ?? 'Stream #$torrentId',
        playback: PlaybackState(
          torrentId: torrentId,
          fileIndex: fileIndex,
          status: stats.playbackState,
          position: Duration(milliseconds: buf.currentPositionBytes ~/ 1000),
          duration: Duration(milliseconds: stats.totalBytesStreamed ~/ 1000),
          bufferProgress: buf.bufferHealthRatio,
          speed: stats.currentBitrateBps / 8388608,
          downloadSpeed: stats.downloadSpeedBps.toDouble(),
          bufferedBytes: buf.bufferedBytes,
        ),
      );
      _startPositionPolling();
    } catch (e) {
      if (!_disposed) state = state.copyWith(error: 'Failed to init stream: $e');
    }
  }

  Future<void> play() async {
    if (_disposed) return;
    try {
      await startStream(torrentId: torrentId, fileIndex: fileIndex);
      if (!_disposed) {
        state = state.copyWith(
          playback: state.playback?.copyWith(status: 'playing'),
        );
      }
    } catch (e) {
      if (!_disposed) state = state.copyWith(error: 'Play failed: $e');
    }
  }

  Future<void> pause() async {
    if (_disposed) return;
    try {
      await pauseStream(torrentId: torrentId, fileIndex: fileIndex);
      if (!_disposed) {
        state = state.copyWith(
          playback: state.playback?.copyWith(status: 'paused'),
        );
      }
    } catch (e) {
      if (!_disposed) state = state.copyWith(error: 'Pause failed: $e');
    }
  }

  Future<void> seek(Duration position) async {
    if (_disposed) return;
    try {
      final offsetBytes = BigInt.from(position.inMilliseconds * 1000);
      await seekStream(torrentId: torrentId, fileIndex: fileIndex, offsetBytes: offsetBytes);
      if (!_disposed) {
        state = state.copyWith(
          playback: state.playback?.copyWith(position: position),
        );
      }
    } catch (e) {
      if (!_disposed) state = state.copyWith(error: 'Seek failed: $e');
    }
  }

  Future<void> stop() async {
    _positionTimer?.cancel();
    _positionTimer = null;
    try {
      await stopStream(torrentId: torrentId, fileIndex: fileIndex);
    } catch (_) {}
    if (!_disposed) {
      state = const StreamState();
    }
  }

  void _startPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_disposed) {
        _positionTimer?.cancel();
        return;
      }
      try {
        final buf = await getBufferStatus(torrentId: torrentId, fileIndex: fileIndex);
        if (_disposed) {
          _positionTimer?.cancel();
          return;
        }
        final stats = await getStreamStatistics(torrentId: torrentId, fileIndex: fileIndex);
        if (_disposed) {
          _positionTimer?.cancel();
          return;
        }
        state = state.copyWith(
          playback: PlaybackState(
            torrentId: torrentId,
            fileIndex: fileIndex,
            status: stats.playbackState,
            position: Duration(milliseconds: buf.currentPositionBytes ~/ 1000),
            duration: Duration(milliseconds: stats.totalBytesStreamed ~/ 1000),
            bufferProgress: buf.bufferHealthRatio,
            speed: stats.currentBitrateBps / 8388608,
            downloadSpeed: stats.downloadSpeedBps.toDouble(),
            bufferedBytes: buf.bufferedBytes,
          ),
        );
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _positionTimer?.cancel();
    _positionTimer = null;
    try {
      stopStream(torrentId: torrentId, fileIndex: fileIndex);
    } catch (_) {}
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider.autoDispose.family<PlayerNotifier, StreamState, ({BigInt torrentId, int fileIndex})>(
  (ref, params) => PlayerNotifier(params.torrentId, params.fileIndex),
);

final streamBufferStatusProvider = FutureProvider.family<FrbBufferStatus, ({BigInt torrentId, int fileIndex})>(
  (ref, params) => getBufferStatus(torrentId: params.torrentId, fileIndex: params.fileIndex),
);

final streamCacheStatusProvider = FutureProvider.family<FrbCacheStatus, ({BigInt torrentId, int fileIndex})>(
  (ref, params) => getCacheStatus(torrentId: params.torrentId, fileIndex: params.fileIndex),
);
