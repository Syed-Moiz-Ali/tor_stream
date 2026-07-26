import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/torrent_box.dart';
import '../../../app/theme.dart';
import '../../home/providers/torrent_list_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late List<TorrentModel> _items;
  bool _isResuming = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() => _items = TorrentBox.instance.getAll());
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Remove all saved stream history items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: TorStreamTheme.accentRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await TorrentBox.instance.clearAll();
      _loadHistory();
    }
  }

  Future<void> _resumeStream(TorrentModel item) async {
    if (_isResuming) return;
    setState(() => _isResuming = true);
    try {
      final torrentId = await addMagnet(magnetUri: item.magnetUri);
      final streamSet = ref.read(streamOnlyTorrentIdsProvider);
      ref.read(streamOnlyTorrentIdsProvider.notifier).state = {...streamSet, torrentId};
      ref.read(torrentListNotifierProvider.notifier).refresh();
      try { await pauseTorrent(id: torrentId); } catch (_) {}
      if (!mounted) return;
      final encodedMagnet = Uri.encodeQueryComponent(item.magnetUri);
      context.push('/player/$torrentId/${item.fileIndex}?streamOnly=true&magnet=$encodedMagnet');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume: $e'),
            backgroundColor: TorStreamTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResuming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: TorStreamTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Watch History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, size: 20),
              tooltip: 'Clear History',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.history_toggle_off_rounded, size: 26,
                      color: cs.onSurface.withValues(alpha: 0.25)),
                  ),
                  const SizedBox(height: 14),
                  Text('No watch history yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Text('Streams you watch are saved locally',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: TorStreamTheme.seedColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.play_circle_fill_rounded,
                                color: TorStreamTheme.seedColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('${item.timeAgoLabel} \u2022 Stream',
                                    style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              color: cs.onSurface.withValues(alpha: 0.3),
                              onPressed: () async {
                                await TorrentBox.instance.remove(item.magnetUri);
                                _loadHistory();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: item.progressRatio),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) => LinearProgressIndicator(
                              value: value,
                              minHeight: 2.5,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation(TorStreamTheme.seedColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.durationMs > 0
                                  ? '${item.formattedPosition} / ${item.formattedDuration}'
                                  : item.formattedPosition,
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: TorStreamTheme.seedColor,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: _isResuming
                                  ? const SizedBox(
                                      width: 12, height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.play_arrow_rounded, size: 16),
                              label: const Text('Resume', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              onPressed: _isResuming ? null : () => _resumeStream(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
