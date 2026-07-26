import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../bridge/generated/types.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 26, color: cs.onSurface.withValues(alpha: 0.25)),
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            )),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(
              fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4),
            )),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: cs.error.withValues(alpha: 0.7)),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            )),
            const SizedBox(height: 4),
            Text(message, style: TextStyle(
              fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4),
            ), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TorrentStatusIcon extends StatelessWidget {
  final FrbTorrentStatus status;
  final double size;

  const TorrentStatusIcon({super.key, required this.status, this.size = 16});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case FrbTorrentStatus.downloading:
        icon = Icons.download_rounded;
        color = TorStreamTheme.seedColor;
      case FrbTorrentStatus.seeding:
        icon = Icons.cloud_done_rounded;
        color = TorStreamTheme.accentGreen;
      case FrbTorrentStatus.paused:
        icon = Icons.pause_circle_outline_rounded;
        color = TorStreamTheme.accentAmber;
      case FrbTorrentStatus.checking:
        icon = Icons.sync_rounded;
        color = TorStreamTheme.textSecondary;
      case FrbTorrentStatus.fetchingMetadata:
        icon = Icons.search_rounded;
        color = TorStreamTheme.textSecondary;
      case FrbTorrentStatus.error:
        icon = Icons.error_outline_rounded;
        color = TorStreamTheme.accentRed;
      case FrbTorrentStatus.queued:
        icon = Icons.hourglass_empty_rounded;
        color = TorStreamTheme.textSecondary;
    }

    return Icon(icon, color: color, size: size);
  }
}


