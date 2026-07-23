import 'package:hive_flutter/hive_flutter.dart';

/// TorrentModel — represents a stream-only torrent stored locally in Hive.
///
/// Used exclusively for streaming (not background downloads).
/// The magnet URI is stored here so we can re-add the torrent to the engine
/// on resume without needing any external file.
class TorrentModel {
  final String magnetUri;
  String title;
  int fileIndex;
  int positionMs;
  int durationMs;
  String lastWatchedAt;

  TorrentModel({
    required this.magnetUri,
    required this.title,
    required this.fileIndex,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatchedAt,
  });

  Map<String, dynamic> toMap() => {
        'magnetUri': magnetUri,
        'title': title,
        'fileIndex': fileIndex,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'lastWatchedAt': lastWatchedAt,
      };

  factory TorrentModel.fromMap(Map<dynamic, dynamic> map) => TorrentModel(
        magnetUri: map['magnetUri'] as String? ?? '',
        title: map['title'] as String? ?? 'Unknown',
        fileIndex: map['fileIndex'] as int? ?? 0,
        positionMs: map['positionMs'] as int? ?? 0,
        durationMs: map['durationMs'] as int? ?? 0,
        lastWatchedAt:
            map['lastWatchedAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);

  double get progressRatio =>
      durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

  String _fmt(Duration d) {
    final s = d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  String get formattedPosition => _fmt(position);
  String get formattedDuration => _fmt(duration);

  String get timeAgoLabel {
    try {
      final dt = DateTime.parse(lastWatchedAt);
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

  /// Deterministic key derived from the magnet URI.
  String get key => magnetUri.trim().toLowerCase().hashCode.toRadixString(16);
}

/// TorrentBox — singleton Hive service for stream-only torrent metadata.
///
/// Box: 'torrent_box' in Hive local storage.
/// Each entry is keyed by a hash of the magnet URI.
///
/// Only stream torrents (temp chunks, auto-delete) are stored here.
/// Background downloads use separate persistence (PlaybackStore).
class TorrentBox {
  TorrentBox._();
  static final TorrentBox instance = TorrentBox._();

  static const _boxName = 'torrent_box';
  Box? _box;

  Box get _b {
    assert(_box != null && _box!.isOpen, 'Call TorrentBox.instance.init() first');
    return _box!;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Upsert a TorrentModel. Used when saving on first stream start and on
  /// every position update.
  Future<void> save(TorrentModel model) async {
    await _b.put(model.key, model.toMap());
  }

  /// Convenience: update only the playback position of an existing entry.
  /// No-op if the magnet URI has never been saved (returns null silently).
  Future<void> savePosition(
    String magnetUri, {
    required int positionMs,
    required int durationMs,
    String? title,
  }) async {
    if (positionMs < 3000) return;
    final key = magnetUri.trim().toLowerCase().hashCode.toRadixString(16);
    final existing = _b.get(key);
    if (existing == null) return;
    final raw = existing as Map;
    final model = TorrentModel(
      magnetUri: raw['magnetUri'] as String? ?? magnetUri,
      title: title ?? (raw['title'] as String? ?? 'Unknown'),
      fileIndex: raw['fileIndex'] as int? ?? 0,
      positionMs: positionMs,
      durationMs: durationMs,
      lastWatchedAt: DateTime.now().toIso8601String(),
    );
    await _b.put(key, model.toMap());
  }

  /// Retrieve a single entry by magnet URI.
  TorrentModel? get(String magnetUri) {
    final key = magnetUri.trim().toLowerCase().hashCode.toRadixString(16);
    final raw = _b.get(key);
    if (raw == null) return null;
    return TorrentModel.fromMap(raw as Map);
  }

  /// All entries sorted by last watched time (newest first).
  List<TorrentModel> getAll() {
    final entries = _b.values
        .map((v) => TorrentModel.fromMap(v as Map))
        .toList();
    entries.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    return entries;
  }

  /// Remove a single entry by magnet URI.
  Future<void> remove(String magnetUri) async {
    final key = magnetUri.trim().toLowerCase().hashCode.toRadixString(16);
    await _b.delete(key);
  }

  /// Wipe all stream torrent metadata from Hive.
  Future<void> clearAll() async {
    await _b.clear();
  }
}
