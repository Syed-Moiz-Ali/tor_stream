import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/services/stream_store.dart';
import '../../home/providers/torrent_list_provider.dart';
import '../providers/add_torrent_provider.dart';

class AddTorrentScreen extends ConsumerStatefulWidget {
  const AddTorrentScreen({super.key});

  @override
  ConsumerState<AddTorrentScreen> createState() => _AddTorrentScreenState();
}

class _AddTorrentScreenState extends ConsumerState<AddTorrentScreen> {
  final _magnetController = TextEditingController();
  bool _isMagnetMode = true;

  @override
  void dispose() {
    _magnetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTorrentStateProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Torrent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Magnet Link'),
                icon: Icon(Icons.link_rounded),
              ),
              ButtonSegment(
                value: false,
                label: Text('Torrent File'),
                icon: Icon(Icons.file_present_rounded),
              ),
            ],
            selected: {_isMagnetMode},
            onSelectionChanged: (v) => setState(() => _isMagnetMode = v.first),
          ),
          const SizedBox(height: 24),
          if (_isMagnetMode) _magnetInput(cs) else _fileInput(cs),
          const SizedBox(height: 24),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ),
          if (state.success == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Torrent added successfully!',
                    style: TextStyle(color: Color(0xFF2ECC71)),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: state.isLoading ? null : _submit,
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(state.isLoading ? 'Adding...' : 'Add Torrent'),
          ),
        ],
      ),
    );
  }

  Widget _magnetInput(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Magnet URI', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _magnetController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'magnet:?xt=urn:btih:...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _fileInput(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select .torrent file',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Browse Files'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isMagnetMode) {
      final magnet = _magnetController.text.trim();
      if (magnet.isEmpty) return;
      ref.read(addTorrentStateProvider.notifier).state = const AddTorrentState(
        isLoading: true,
      );
      try {
        final id = await ref.read(addMagnetLinkProvider(magnet).future);
        if (!mounted) return;
        ref.read(addTorrentStateProvider.notifier).state = AddTorrentState(
          success: true,
          torrentId: id,
        );
        _showPostAddDialog(id, magnetUri: magnet);
      } catch (e) {
        if (!mounted) return;
        ref.read(addTorrentStateProvider.notifier).state = AddTorrentState(
          error: 'Failed to add torrent: $e',
        );
      }
    }
  }

  void _showPostAddDialog(BigInt torrentId, {required String magnetUri}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 28),
                SizedBox(width: 12),
                Text('Torrent Added!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Would you like to start live streaming right now or download silently in the background?',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C6EF8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Stream Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () async {
                // 1. Mark as stream-only so the home screen never shows it.
                final streamSet = ref.read(streamOnlyTorrentIdsProvider);
                ref.read(streamOnlyTorrentIdsProvider.notifier).state = {...streamSet, torrentId};
                ref.read(torrentListNotifierProvider.notifier).refresh();

                // 2. Capture navigation objects before any async gap.
                final nav = Navigator.of(ctx);
                final router = GoRouter.of(context);

                // 3. Persist the magnet URI to Hive so we can resume later
                //    even after the app is killed and the torrent removed.
                await StreamStore.instance.save(StreamHistoryEntry(
                  magnetUri: magnetUri,
                  title: 'Loading…',        // will be updated once metadata arrives
                  fileIndex: 0,
                  positionMs: 0,
                  durationMs: 0,
                  lastWatchedAt: DateTime.now().toIso8601String(),
                ));

                // 4. Pause the torrent — librqbit will only fetch pieces the
                //    streaming server explicitly requests, nothing is written
                //    to the permanent download directory.
                try {
                  await pauseTorrent(id: torrentId);
                } catch (_) {}

                // 5. Navigate to player, carrying the magnetUri so it can be
                //    used to re-add the torrent on resume.
                nav.pop();
                final encodedMagnet = Uri.encodeQueryComponent(magnetUri);
                router.pushReplacement(
                  '/player/$torrentId/0?streamOnly=true&magnet=$encodedMagnet',
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.download_rounded, size: 20, color: Colors.white),
              label: const Text('Download in Background', style: TextStyle(fontSize: 15, color: Colors.white)),
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
