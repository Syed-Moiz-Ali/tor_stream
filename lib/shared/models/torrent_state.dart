import '../../bridge/generated/types.dart';

class TorrentState {
  final BigInt id;
  final String infoHash;
  final String name;
  final FrbTorrentStatus status;
  final double progress;
  final int downloadSpeed;
  final int uploadSpeed;
  final int totalSize;
  final int downloaded;
  final int numPeers;
  final String savePath;
  final int addedAtMs;

  const TorrentState({
    required this.id,
    required this.infoHash,
    required this.name,
    required this.status,
    required this.progress,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.totalSize,
    required this.downloaded,
    required this.numPeers,
    required this.savePath,
    required this.addedAtMs,
  });

  factory TorrentState.fromFrb(FrbTorrentInfo info) {
    return TorrentState(
      id: info.id,
      infoHash: info.infoHash,
      name: info.name ?? 'Unknown',
      status: info.status,
      progress: info.progress,
      downloadSpeed: info.downloadRate,
      uploadSpeed: info.uploadRate,
      totalSize: info.totalBytes,
      downloaded: info.downloadedBytes,
      numPeers: info.numPeers,
      savePath: info.savePath,
      addedAtMs: info.addedAtMs,
    );
  }

  bool get isDownloading => status == FrbTorrentStatus.downloading;
  bool get isSeeding => status == FrbTorrentStatus.seeding;
  bool get isPaused => status == FrbTorrentStatus.paused;
  bool get isChecking => status == FrbTorrentStatus.checking;
  bool get isError => status == FrbTorrentStatus.error;
  bool get isFetchingMetadata => status == FrbTorrentStatus.fetchingMetadata;

  String get statusLabel {
    switch (status) {
      case FrbTorrentStatus.queued:
        return 'Queued';
      case FrbTorrentStatus.checking:
        return 'Checking';
      case FrbTorrentStatus.fetchingMetadata:
        return 'Fetching Metadata';
      case FrbTorrentStatus.downloading:
        return 'Downloading';
      case FrbTorrentStatus.seeding:
        return 'Seeding';
      case FrbTorrentStatus.paused:
        return 'Paused';
      case FrbTorrentStatus.error:
        return 'Error';
    }
  }

  String get formattedSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1048576) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1073741824) return '${(totalSize / 1048576).toStringAsFixed(1)} MB';
    return '${(totalSize / 1073741824).toStringAsFixed(2)} GB';
  }

  String get formattedDownloaded {
    if (downloaded < 1024) return '$downloaded B';
    if (downloaded < 1048576) return '${(downloaded / 1024).toStringAsFixed(1)} KB';
    if (downloaded < 1073741824) return '${(downloaded / 1048576).toStringAsFixed(1)} MB';
    return '${(downloaded / 1073741824).toStringAsFixed(2)} GB';
  }

  String get formattedSpeed {
    if (downloadSpeed < 1024) return '$downloadSpeed B/s';
    if (downloadSpeed < 1048576) return '${(downloadSpeed / 1024).toStringAsFixed(1)} KB/s';
    return '${(downloadSpeed / 1048576).toStringAsFixed(1)} MB/s';
  }

  int? get etaSeconds {
    if (downloadSpeed <= 0 || progress >= 1.0) return null;
    return ((totalSize - downloaded) / downloadSpeed).round();
  }

  String get formattedEta {
    final s = etaSeconds;
    if (s == null || s <= 0) return '--';
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${sec}s';
    return '${sec}s';
  }
}

class FileEntry {
  final int index;
  final String path;
  final String name;
  final int size;
  final String mediaType;
  final String category;

  const FileEntry({
    required this.index,
    required this.path,
    required this.name,
    required this.size,
    required this.mediaType,
    required this.category,
  });

  factory FileEntry.fromFrb(FrbMediaFile file) {
    return FileEntry(
      index: file.fileIndex,
      path: file.path,
      name: file.fileName,
      size: file.size,
      mediaType: file.mediaType,
      category: file.category,
    );
  }

  factory FileEntry.fromRaw(FrbRawFileEntry entry) {
    final parts = entry.path.split('/');
    return FileEntry(
      index: entry.index,
      path: entry.path,
      name: parts.isNotEmpty ? parts.last : entry.path,
      size: entry.size,
      mediaType: 'unknown',
      category: 'unknown',
    );
  }

  bool get isVideo => mediaType == 'video';
  bool get isAudio => mediaType == 'audio';
  bool get isSubtitle => mediaType == 'subtitle';

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1073741824) return '${(size / 1048576).toStringAsFixed(1)} MB';
    return '${(size / 1073741824).toStringAsFixed(2)} GB';
  }
}
