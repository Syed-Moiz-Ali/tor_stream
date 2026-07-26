import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/generated/types.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../app/theme.dart';
import '../providers/torrent_list_provider.dart';

class TorrentTile extends ConsumerWidget {
  final TorrentState torrent;

  const TorrentTile({super.key, required this.torrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/player/${torrent.id}/${0}');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildThumbnail(cs),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(torrent.name,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.9),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _statusBadge(cs),
                            const SizedBox(width: 6),
                            Text(torrent.formattedSize,
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildMenuButton(context, ref, cs),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(cs),
              const SizedBox(height: 10),
              _buildFooter(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme cs) {
    final color = torrent.isCompleted
        ? TorStreamTheme.accentGreen
        : torrent.isPaused
            ? TorStreamTheme.accentAmber
            : TorStreamTheme.seedColor;

    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        torrent.isCompleted
            ? Icons.check_circle_rounded
            : torrent.isPaused
                ? Icons.pause_circle_rounded
                : Icons.movie_rounded,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _statusBadge(ColorScheme cs) {
    final color = torrent.isCompleted
        ? TorStreamTheme.accentGreen
        : switch (torrent.status) {
            FrbTorrentStatus.downloading => TorStreamTheme.seedColor,
            FrbTorrentStatus.seeding => TorStreamTheme.accentGreen,
            FrbTorrentStatus.paused => TorStreamTheme.accentAmber,
            FrbTorrentStatus.error => TorStreamTheme.accentRed,
            FrbTorrentStatus.fetchingMetadata => const Color(0xFF3498DB),
            _ => TorStreamTheme.textSecondary,
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (torrent.isDownloading)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SizedBox(
                width: 8, height: 8,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
              ),
            ),
          Text(torrent.statusLabel,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme cs) {
    final progress = torrent.progress;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 4,
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: cs.onSurface.withValues(alpha: 0.08),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TorStreamTheme.seedColor,
                          torrent.isCompleted
                              ? TorStreamTheme.accentGreen
                              : TorStreamTheme.seedColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ColorScheme cs) {
    return Row(
      children: [
        if (torrent.isDownloading || torrent.isSeeding) ...[
          Icon(Icons.speed_rounded, size: 11,
            color: cs.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 3),
          Text(torrent.formattedSpeed,
            style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45))),
          const SizedBox(width: 12),
          Icon(Icons.people_rounded, size: 11,
            color: cs.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 3),
          Text('${torrent.numPeers} peers',
            style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45))),
        ],
        if (torrent.isDownloading && torrent.etaSeconds != null) ...[
          const Spacer(),
          Icon(Icons.schedule_rounded, size: 11,
            color: cs.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 3),
          Text(torrent.formattedEta,
            style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45))),
        ],
        if (torrent.isCompleted || torrent.isPaused) ...[
          const Spacer(),
          Icon(Icons.check_rounded, size: 11,
            color: TorStreamTheme.accentGreen.withValues(alpha: 0.5)),
          const SizedBox(width: 3),
          Text(torrent.isCompleted ? 'Done' : 'Paused',
            style: TextStyle(fontSize: 10,
              color: torrent.isCompleted
                  ? TorStreamTheme.accentGreen.withValues(alpha: 0.5)
                  : TorStreamTheme.accentAmber.withValues(alpha: 0.5))),
        ],
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref, ColorScheme cs) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handleAction(context, ref, action),
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz_rounded, size: 18,
        color: cs.onSurface.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: TorStreamTheme.surfaceElevated,
      itemBuilder: (_) => [
        if (torrent.isPaused)
          _menuItem(Icons.play_arrow_rounded, 'Resume', 'resume')
        else
          _menuItem(Icons.pause_rounded, 'Pause', 'pause'),
        _menuItem(Icons.delete_outline_rounded, 'Remove', 'remove'),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'pause':
        HapticFeedback.mediumImpact();
        ref.read(pauseTorrentProvider(torrent.id));
      case 'resume':
        HapticFeedback.mediumImpact();
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
