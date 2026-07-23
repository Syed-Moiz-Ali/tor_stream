import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/torrent_box.dart';
import '../../../app/theme.dart';
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
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Magnet'),
                icon: Icon(Icons.link_rounded, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text('File'),
                icon: Icon(Icons.file_present_rounded, size: 18),
              ),
            ],
            selected: {_isMagnetMode},
            onSelectionChanged: (v) => setState(() => _isMagnetMode = v.first),
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
          const SizedBox(height: 28),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isMagnetMode ? _magnetInput(cs) : _fileInput(cs),
          ),
          const SizedBox(height: 28),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: TorStreamTheme.accentRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TorStreamTheme.accentRed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: TorStreamTheme.accentRed),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.error!, style: TextStyle(color: TorStreamTheme.accentRed, fontSize: 13))),
                  ],
                ),
              ),
            ),
          if (state.success == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: TorStreamTheme.accentGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TorStreamTheme.accentGreen.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: TorStreamTheme.accentGreen),
                    SizedBox(width: 8),
                    Text('Torrent added successfully!', style: TextStyle(color: TorStreamTheme.accentGreen, fontSize: 13)),
                  ],
                ),
              ),
            ),
          FilledButton.icon(
            onPressed: state.isLoading ? null : _submit,
            icon: state.isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add_rounded, size: 20),
            label: Text(state.isLoading ? 'Adding...' : 'Add to Library'),
          ),
        ],
      ),
    );
  }

  Widget _magnetInput(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Magnet Link', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: TorStreamTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _magnetController,
          maxLines: 4,
          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: 'magnet:?xt=urn:btih:...',
            hintStyle: TextStyle(color: TorStreamTheme.textSecondary.withValues(alpha: 0.5), fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _fileInput(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Torrent File', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: TorStreamTheme.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: TorStreamTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TorStreamTheme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(Icons.upload_file_rounded, size: 32, color: TorStreamTheme.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text('Tap to browse .torrent files',
                style: TextStyle(fontSize: 13, color: TorStreamTheme.textSecondary.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isMagnetMode) {
      final magnet = _magnetController.text.trim();
      if (magnet.isEmpty) return;
      ref.read(addTorrentStateProvider.notifier).state = const AddTorrentState(isLoading: true);
      try {
        final id = await ref.read(addMagnetLinkProvider(magnet).future);
        if (!mounted) return;
        ref.read(addTorrentStateProvider.notifier).state = AddTorrentState(success: true, torrentId: id);
        _showPostAddDialog(id, magnetUri: magnet);
      } catch (e) {
        if (!mounted) return;
        ref.read(addTorrentStateProvider.notifier).state = AddTorrentState(error: 'Failed to add torrent: $e');
      }
    }
  }

  void _showPostAddDialog(BigInt torrentId, {required String magnetUri}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: TorStreamTheme.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: TorStreamTheme.accentGreen, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Torrent Added', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text('Stream now or download in background',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Stream Now'),
              onPressed: () async {
                final streamSet = ref.read(streamOnlyTorrentIdsProvider);
                ref.read(streamOnlyTorrentIdsProvider.notifier).state = {...streamSet, torrentId};
                ref.read(torrentListNotifierProvider.notifier).refresh();

                final nav = Navigator.of(ctx);
                final router = GoRouter.of(context);

                await TorrentBox.instance.save(TorrentModel(
                  magnetUri: magnetUri,
                  title: 'Loading…',
                  fileIndex: 0,
                  positionMs: 0,
                  durationMs: 0,
                  lastWatchedAt: DateTime.now().toIso8601String(),
                ));

                try { await pauseTorrent(id: torrentId); } catch (_) {}

                nav.pop();
                final encodedMagnet = Uri.encodeQueryComponent(magnetUri);
                router.pushReplacement('/player/$torrentId/0?streamOnly=true&magnet=$encodedMagnet');
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Download in Background'),
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
