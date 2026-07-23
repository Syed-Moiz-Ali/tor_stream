class PlaybackState {
  final BigInt torrentId;
  final int fileIndex;
  final String status;
  final Duration position;
  final Duration duration;
  final double bufferProgress;
  final double speed;
  final double downloadSpeed;
  final int bufferedBytes;

  const PlaybackState({
    required this.torrentId,
    required this.fileIndex,
    required this.status,
    required this.position,
    required this.duration,
    required this.bufferProgress,
    required this.speed,
    required this.downloadSpeed,
    required this.bufferedBytes,
  });

  bool get isPlaying => status == 'playing';
  bool get isPaused => status == 'paused';
  bool get isBuffering => status == 'buffering';
  bool get isCompleted => status == 'completed';
  bool get isIdle => status == 'idle';
  bool get isError => status == 'error';

  PlaybackState copyWith({
    BigInt? torrentId,
    int? fileIndex,
    String? status,
    Duration? position,
    Duration? duration,
    double? bufferProgress,
    double? speed,
    double? downloadSpeed,
    int? bufferedBytes,
  }) {
    return PlaybackState(
      torrentId: torrentId ?? this.torrentId,
      fileIndex: fileIndex ?? this.fileIndex,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferProgress: bufferProgress ?? this.bufferProgress,
      speed: speed ?? this.speed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      bufferedBytes: bufferedBytes ?? this.bufferedBytes,
    );
  }

  String get positionFormatted => _formatDuration(position);
  String get durationFormatted => _formatDuration(duration);
  String get remainingFormatted => _formatDuration(duration - position);

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
