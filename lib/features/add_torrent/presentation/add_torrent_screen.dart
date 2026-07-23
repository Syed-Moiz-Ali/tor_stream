import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF2ECC71),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
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
      final navigator = context.pop;
      ref.read(addTorrentStateProvider.notifier).state = const AddTorrentState(
        isLoading: true,
      );
      final id = await ref.read(addMagnetLinkProvider(magnet).future);
      if (!context.mounted) return;
      ref.read(addTorrentStateProvider.notifier).state = AddTorrentState(
        success: true,
        torrentId: id,
      );
      Future.delayed(const Duration(seconds: 1), navigator);
    }
  }
}
