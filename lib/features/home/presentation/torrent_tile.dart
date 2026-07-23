import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/generated/types.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/speed_indicator.dart';
import '../../../app/theme.dart';
import '../providers/torrent_list_provider.dart';

class TorrentTile extends ConsumerWidget {
  final TorrentState torrent;

  const TorrentTile({super.key, required this.torrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/player/${torrent.id}/${0}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TorStreamTheme.seedColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      torrent.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.movie_rounded,
                      color: torrent.isCompleted
                          ? TorStreamTheme.accentGreen
                          : TorStreamTheme.seedColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(torrent.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _statusChip(torrent.statusLabel),
                            const SizedBox(width: 8),
                            Text(torrent.formattedSize,
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(context, ref, action),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz_rounded, size: 20,
                      color: cs.onSurface.withValues(alpha: 0.4)),
                    itemBuilder: (_) => [
                      if (torrent.isPaused)
                        const PopupMenuItem(value: 'resume', child: Text('Resume'))
                      else
                        const PopupMenuItem(value: 'pause', child: Text('Pause')),
                      const PopupMenuItem(value: 'remove', child: Text('Remove')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBar(progress: torrent.progress, height: 4),
              const SizedBox(height: 10),
              Row(
                children: [
                  SpeedIndicator(
                    downloadSpeed: torrent.downloadSpeed,
                    uploadSpeed: torrent.uploadSpeed,
                  ),
                  const Spacer(),
                  if (torrent.isDownloading && torrent.etaSeconds != null) ...[
                    Icon(Icons.timer_outlined, size: 12,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                    const SizedBox(width: 4),
                    Text(torrent.formattedEta,
                      style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                    const SizedBox(width: 12),
                  ],
                  Row(
                    children: [
                      Icon(Icons.people_rounded, size: 14,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                      const SizedBox(width: 4),
                      Text('${torrent.numPeers}',
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    final color = torrent.isCompleted
        ? TorStreamTheme.accentGreen
        : switch (torrent.status) {
            FrbTorrentStatus.downloading => TorStreamTheme.seedColor,
            FrbTorrentStatus.seeding => TorStreamTheme.accentGreen,
            FrbTorrentStatus.paused => TorStreamTheme.accentAmber,
            FrbTorrentStatus.error => TorStreamTheme.accentRed,
            FrbTorrentStatus.checking => const Color(0xFF9B59B6),
            FrbTorrentStatus.fetchingMetadata => const Color(0xFF3498DB),
            FrbTorrentStatus.queued => TorStreamTheme.textSecondary,
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
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
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Torrent'),
            content: const Text('Delete downloaded files as well?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(removeTorrentProvider((id: torrent.id, deleteFiles: false)));
                  Navigator.pop(ctx);
                },
                child: const Text('Remove Only'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(removeTorrentProvider((id: torrent.id, deleteFiles: true)));
                  Navigator.pop(ctx);
                },
                child: const Text('Delete Files'),
              ),
            ],
          ),
        );
    }
  }
}
