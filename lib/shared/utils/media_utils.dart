import '../../bridge/generated/types.dart';

String extractQualityTag(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.contains('2160p') || lower.contains('4k') || lower.contains('uhd')) return '4K';
  if (lower.contains('1080p') || lower.contains('full.hd') || lower.contains('fhd')) return '1080p';
  if (lower.contains('720p') || lower.contains('hd')) return '720p';
  if (lower.contains('480p') || lower.contains('dvd')) return '480p';
  if (lower.contains('360p')) return '360p';
  return '';
}

String extractCodecTag(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.contains('hevc') || lower.contains('x265') || lower.contains('h.265')) return 'HEVC';
  if (lower.contains('x264') || lower.contains('h.264') || lower.contains('avc')) return 'H.264';
  if (lower.contains('av1')) return 'AV1';
  if (lower.contains('vp9')) return 'VP9';
  return '';
}

String extractSourceTag(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.contains('web-dl') || lower.contains('webdl') || lower.contains('web')) return 'WEB-DL';
  if (lower.contains('bluray') || lower.contains('blu-ray') || lower.contains('bd')) return 'BluRay';
  if (lower.contains('dvd') || lower.contains('dvdrip')) return 'DVD';
  if (lower.contains('hdtv') || lower.contains('hdtvrip')) return 'HDTV';
  if (lower.contains('cam') || lower.contains('ts') && !lower.contains('m2ts')) return 'CAM';
  return '';
}

String formatResolution(int width, int height) {
  if (height >= 2160) return '4K';
  if (height >= 1080) return '1080p';
  if (height >= 720) return '720p';
  if (height >= 480) return '480p';
  return '${height}p';
}

List<String> getFileTags(FrbMediaFile file) {
  final tags = <String>[];
  final q = extractQualityTag(file.fileName);
  if (q.isNotEmpty) tags.add(q);
  final c = extractCodecTag(file.fileName);
  if (c.isNotEmpty) tags.add(c);
  final s = extractSourceTag(file.fileName);
  if (s.isNotEmpty) tags.add(s);

  if (tags.isEmpty && file.videoInfo != null) {
    tags.add(formatResolution(file.videoInfo!.width, file.videoInfo!.height));
  }

  if (tags.isEmpty) {
    tags.add(file.extension_.toUpperCase());
  }

  return tags;
}
