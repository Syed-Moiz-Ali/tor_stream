import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PlaybackHistoryItem {
  final String torrentId;
  final int fileIndex;
  final String title;
  final int positionMs;
  final int durationMs;
  final String updatedAt;

  PlaybackHistoryItem({
    required this.torrentId,
    required this.fileIndex,
    required this.title,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'torrentId': torrentId,
        'fileIndex': fileIndex,
        'title': title,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'updatedAt': updatedAt,
      };

  factory PlaybackHistoryItem.fromJson(Map<String, dynamic> json) =>
      PlaybackHistoryItem(
        torrentId: json['torrentId'] as String,
        fileIndex: json['fileIndex'] as int,
        title: json['title'] as String? ?? 'Torrent #${json['torrentId']}',
        positionMs: json['positionMs'] as int,
        durationMs: json['durationMs'] as int,
        updatedAt: json['updatedAt'] as String,
      );

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);

  double get progressRatio => durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

  String _formatTime(Duration d) {
    final s = d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get formattedPosition => _formatTime(position);
  String get formattedDuration => _formatTime(duration);

  String get timeAgoLabel {
    try {
      final dt = DateTime.parse(updatedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class PlaybackStore {
  PlaybackStore._();
  static final PlaybackStore instance = PlaybackStore._();

  File? _file;
  Map<String, PlaybackHistoryItem> _cache = {};

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}/playback_history.json');
      if (await _file!.exists()) {
        final content = await _file!.readAsString();
        if (content.isNotEmpty) {
          final Map<String, dynamic> decoded = jsonDecode(content);
          _cache = decoded.map(
            (k, v) => MapEntry(k, PlaybackHistoryItem.fromJson(v)),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to load playback history: $e');
    }
  }

  String _key(BigInt torrentId, int fileIndex) => '${torrentId}_$fileIndex';

  List<PlaybackHistoryItem> getAllHistory() {
    final list = _cache.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  PlaybackHistoryItem? getHistory(BigInt torrentId, int fileIndex) {
    return _cache[_key(torrentId, fileIndex)];
  }

  Duration? getPosition(BigInt torrentId, int fileIndex) {
    return getHistory(torrentId, fileIndex)?.position;
  }

  Future<void> savePosition({
    required BigInt torrentId,
    required int fileIndex,
    required String title,
    required Duration position,
    required Duration duration,
  }) async {
    if (position.inSeconds <= 2) return;

    final key = _key(torrentId, fileIndex);
    final item = PlaybackHistoryItem(
      torrentId: torrentId.toString(),
      fileIndex: fileIndex,
      title: title.isNotEmpty ? title : 'Torrent #$torrentId',
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds,
      updatedAt: DateTime.now().toIso8601String(),
    );

    _cache[key] = item;
    await _flush();
  }

  Future<void> clearHistory(BigInt torrentId, int fileIndex) async {
    _cache.remove(_key(torrentId, fileIndex));
    await _flush();
  }

  Future<void> clearAllHistory() async {
    _cache.clear();
    await _flush();
  }

  Future<void> _flush() async {
    try {
      if (_file != null) {
        final map = _cache.map((k, v) => MapEntry(k, v.toJson()));
        await _file!.writeAsString(jsonEncode(map));
      }
    } catch (e) {
      debugPrint('Failed to save playback history: $e');
    }
  }
}
