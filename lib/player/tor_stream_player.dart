import 'package:flutter/services.dart';

/// Flutter player wrapper for Android Media3 delivery layer.
class TorStreamPlayer {
  static const MethodChannel _channel = MethodChannel('tor_stream/player');

  /// Prepare Media3 ExoPlayer stream for a torrent file.
  static Future<bool> prepareStream({
    required BigInt torrentId,
    required int fileIndex,
    required BigInt fileSize,
    String title = 'TorStream',
  }) async {
    final bool? result = await _channel.invokeMethod<bool>('prepareStream', {
      'torrentId': torrentId.toInt(),
      'fileIndex': fileIndex,
      'fileSize': fileSize.toInt(),
      'title': title,
    });
    return result ?? false;
  }

  /// Start or resume playback.
  static Future<bool> play() async {
    final bool? result = await _channel.invokeMethod<bool>('play');
    return result ?? false;
  }

  /// Pause playback.
  static Future<bool> pause() async {
    final bool? result = await _channel.invokeMethod<bool>('pause');
    return result ?? false;
  }

  /// Seek to position in milliseconds.
  static Future<bool> seek(Duration position) async {
    final bool? result = await _channel.invokeMethod<bool>('seekTo', {
      'positionMs': position.inMilliseconds,
    });
    return result ?? false;
  }

  /// Stop playback and release player resources.
  static Future<bool> stop() async {
    final bool? result = await _channel.invokeMethod<bool>('stop');
    return result ?? false;
  }

  /// Query current Android Media3 playback state.
  static Future<String> getPlaybackState() async {
    final String? state = await _channel.invokeMethod<String>('getPlaybackState');
    return state ?? 'idle';
  }

  /// Query current playback position in milliseconds.
  static Future<Duration> getPosition() async {
    final int? ms = await _channel.invokeMethod<int>('getPositionMs');
    return Duration(milliseconds: ms ?? 0);
  }

  /// Query duration in milliseconds.
  static Future<Duration> getDuration() async {
    final int? ms = await _channel.invokeMethod<int>('getDurationMs');
    return Duration(milliseconds: ms ?? 0);
  }
}
