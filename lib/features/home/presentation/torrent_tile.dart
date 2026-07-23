import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/generated/types.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/speed_indicator.dart';
import '../providers/torrent_list_provider.dart';

class TorrentTile extends ConsumerWidget {
  final TorrentState torrent;

  const TorrentTile({super.key, required this.torrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/player/${torrent.id}/${0}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(torrent.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  _statusChip(torrent.statusLabel, cs),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(torrent.formattedDownloaded,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  Text(' / ${torrent.formattedSize}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
                  const Spacer(),
                  Text(torrent.formattedEta,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(progress: torrent.progress),
              const SizedBox(height: 8),
              Row(
                children: [
                  SpeedIndicator(
                    downloadSpeed: torrent.downloadSpeed,
                    uploadSpeed: torrent.uploadSpeed,
                  ),
                  const Spacer(),
                  Icon(Icons.people_rounded, size: 14,
                    color: cs.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text('${torrent.numPeers}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(context, ref, action),
                    itemBuilder: (_) => [
                      if (torrent.isPaused)
                        const PopupMenuItem(value: 'resume', child: Text('Resume'))
                      else
                        const PopupMenuItem(value: 'pause', child: Text('Pause')),
                      const PopupMenuItem(value: 'remove', child: Text('Remove')),
                    ],
                    child: Icon(Icons.more_vert_rounded, size: 18,
                      color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, ColorScheme cs) {
    final color = torrent.isCompleted
        ? const Color(0xFF2ECC71)
        : switch (torrent.status) {
            FrbTorrentStatus.downloading => const Color(0xFF7C6EF8),
            FrbTorrentStatus.seeding => const Color(0xFF2ECC71),
            FrbTorrentStatus.paused => const Color(0xFFFFB347),
            FrbTorrentStatus.error => const Color(0xFFE74C3C),
            FrbTorrentStatus.checking => const Color(0xFF9B59B6),
            FrbTorrentStatus.fetchingMetadata => const Color(0xFF3498DB),
            FrbTorrentStatus.queued => const Color(0xFF6B6B80),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (torrent.isCompleted) ...[
            const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF2ECC71)),
            const SizedBox(width: 4),
          ],
          Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pause':
        ref.read(pauseTorrentProvider(torrent.id));
      case 'resume':
        ref.read(resumeTorrentProvider(torrent.id));
      case 'remove':
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove Torrent'),
            content: const Text('Delete downloaded files as well?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(removeTorrentProvider((id: torrent.id, deleteFiles: false)));
                  Navigator.pop(context);
                },
                child: const Text('Remove Only'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(removeTorrentProvider((id: torrent.id, deleteFiles: true)));
                  Navigator.pop(context);
                },
                child: const Text('Delete Files'),
              ),
            ],
          ),
        );
    }
  }
}
