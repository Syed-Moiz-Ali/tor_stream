import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/services/stream_store.dart';
import '../../home/providers/torrent_list_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late List<StreamHistoryEntry> _items;
  bool _isResuming = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _items = StreamStore.instance.getAll();
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Watch History?'),
        content: const Text('This will remove all saved stream history items.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StreamStore.instance.clearAll();
      _loadHistory();
    }
  }

  Future<void> _resumeStream(StreamHistoryEntry item) async {
    if (_isResuming) return;
    setState(() => _isResuming = true);

    try {
      // 1. Add magnet link to session
      final torrentId = await addMagnet(magnetUri: item.magnetUri);

      // 2. Mark as stream-only so Home tab hides it
      final streamSet = ref.read(streamOnlyTorrentIdsProvider);
      ref.read(streamOnlyTorrentIdsProvider.notifier).state = {...streamSet, torrentId};
      ref.read(torrentListNotifierProvider.notifier).refresh();

      // 3. Pause torrent so it doesn't download full file eagerly
      try {
        await pauseTorrent(id: torrentId);
      } catch (_) {}

      if (!mounted) return;
      final encodedMagnet = Uri.encodeQueryComponent(item.magnetUri);
      context.push('/player/$torrentId/${item.fileIndex}?streamOnly=true&magnet=$encodedMagnet');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume stream: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResuming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Watch History'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
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
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 64,
                    color: cs.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No watch history yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Streams you watch will be saved locally in Hive so you can resume them anytime',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C6EF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Color(0xFF7C6EF8),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.timeAgoLabel} • Stream',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: cs.onSurface.withValues(alpha: 0.4),
                              onPressed: () async {
                                await StreamStore.instance.remove(item.magnetUri);
                                _loadHistory();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progressRatio,
                            minHeight: 4,
                            backgroundColor: cs.surfaceContainerHighest,
                            color: const Color(0xFF7C6EF8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.durationMs > 0
                                  ? 'Stopped at ${item.formattedPosition} / ${item.formattedDuration}'
                                  : 'Stopped at ${item.formattedPosition}',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF7C6EF8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: _isResuming
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.play_arrow_rounded, size: 18),
                              label: const Text(
                                'Resume Stream',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
