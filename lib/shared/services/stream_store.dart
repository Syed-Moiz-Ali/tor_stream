/// StreamStore — Hive-backed persistence for stream-only history.
///
/// Each entry stores:
///   - magnetUri   → used to re-add the torrent on resume
///   - title       → displayed in watch history
///   - fileIndex   → which file inside the torrent to stream
///   - positionMs  → last watched position in milliseconds
///   - durationMs  → total duration in milliseconds (0 until known)
///   - lastWatchedAt → ISO-8601 string of the last update
///
/// Hive box name: 'stream_history'
/// Key: magnetUri (normalized to lowercase trimmed string)

library;

import 'package:hive_flutter/hive_flutter.dart';

const _kBoxName = 'stream_history';

class StreamHistoryEntry {
  final String magnetUri;
  final String title;
  final int fileIndex;
  final int positionMs;
  final int durationMs;
  final String lastWatchedAt;

  StreamHistoryEntry({
    required this.magnetUri,
    required this.title,
    required this.fileIndex,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatchedAt,
  });

  // ── Hive map serialisation ────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'magnetUri': magnetUri,
        'title': title,
        'fileIndex': fileIndex,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'lastWatchedAt': lastWatchedAt,
      };

  factory StreamHistoryEntry.fromMap(Map<dynamic, dynamic> map) =>
      StreamHistoryEntry(
        magnetUri: map['magnetUri'] as String? ?? '',
        title: map['title'] as String? ?? 'Unknown',
        fileIndex: map['fileIndex'] as int? ?? 0,
        positionMs: map['positionMs'] as int? ?? 0,
        durationMs: map['durationMs'] as int? ?? 0,
        lastWatchedAt:
            map['lastWatchedAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  // ── Convenience helpers ───────────────────────────────────────────────────

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

  /// Magnet hash used as the Hive box key.
  static String keyFor(String magnetUri) =>
      magnetUri.trim().toLowerCase().hashCode.toRadixString(16);

  String get key => keyFor(magnetUri);

  StreamHistoryEntry copyWith({
    int? positionMs,
    int? durationMs,
    String? title,
    String? lastWatchedAt,
  }) =>
      StreamHistoryEntry(
        magnetUri: magnetUri,
        title: title ?? this.title,
        fileIndex: fileIndex,
        positionMs: positionMs ?? this.positionMs,
        durationMs: durationMs ?? this.durationMs,
        lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      );
}

// ── StreamStore singleton ─────────────────────────────────────────────────────

class StreamStore {
  StreamStore._();
  static final StreamStore instance = StreamStore._();

  Box? _box;

  Box get _b {
    assert(_box != null && _box!.isOpen, 'Call StreamStore.instance.init() first');
    return _box!;
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_kBoxName);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Upsert a stream entry.
  ///
  /// Call this when the user picks "Stream Now" (with positionMs=0) and again
  /// on every player position update.
  Future<void> save(StreamHistoryEntry entry) async {
    await _b.put(entry.key, entry.toMap());
  }

  /// Save only the playback position for an existing entry.
  ///
  /// No-op if the entry doesn't exist.
  Future<void> savePosition(
    String magnetUri, {
    required int positionMs,
    required int durationMs,
    String? title,
  }) async {
    // Don't save the very start — ignore first 3 s.
    if (positionMs < 3000) return;

    final key = StreamHistoryEntry.keyFor(magnetUri);
    final existing = _b.get(key);
    if (existing == null) return;

    final entry =
        StreamHistoryEntry.fromMap(existing as Map).copyWith(
      positionMs: positionMs,
      durationMs: durationMs,
      title: title,
      lastWatchedAt: DateTime.now().toIso8601String(),
    );
    await _b.put(key, entry.toMap());
  }

  /// Retrieve a single entry by magnet URI (or null if not found).
  StreamHistoryEntry? get(String magnetUri) {
    final raw = _b.get(StreamHistoryEntry.keyFor(magnetUri));
    if (raw == null) return null;
    return StreamHistoryEntry.fromMap(raw as Map);
  }

  /// All entries sorted newest first.
  List<StreamHistoryEntry> getAll() {
    final entries = _b.values
        .map((v) => StreamHistoryEntry.fromMap(v as Map))
        .toList();
    entries.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    return entries;
  }

  /// Remove one entry (called after the user taps the × button in history).
  Future<void> remove(String magnetUri) async {
    await _b.delete(StreamHistoryEntry.keyFor(magnetUri));
  }

  /// Wipe all stream history.
  Future<void> clearAll() async {
    await _b.clear();
  }
}
