import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/torrent_box.dart';
import '../../../app/theme.dart';
import '../providers/torrent_list_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final torrentsAsync = ref.watch(torrentListNotifierProvider);
    final activeCount =
        torrentsAsync.valueOrNull?.where((t) => t.isDownloading).length ?? 0;
    final completedCount =
        torrentsAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(cs),
            _buildQuickActionsSliver(cs),
            _buildLibraryCard(cs, activeCount, completedCount),
            _buildAddContentSection(cs),
            _buildTipsSection(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TorStream',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    _iconButton(
                      Icons.history_rounded,
                      'History',
                      () => context.push('/history'),
                      cs,
                    ),
                    const SizedBox(width: 4),
                    _iconButton(
                      Icons.tune_rounded,
                      'Settings',
                      () => context.push('/settings'),
                      cs,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Stream torrents instantly \u2014 no waiting, no hassle.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
    ColorScheme cs,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSliver(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.link_rounded,
                label: 'Magnet Link',
                gradientColors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
                onTap: () => _showMagnetSheet(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.file_present_rounded,
                label: 'Torrent File',
                gradientColors: [
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                ],
                onTap: () => _pickTorrentFile(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            gradient: LinearGradient(
              colors: gradientColors
                  .map((c) => c.withValues(alpha: 0.12))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: gradientColors.first.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: gradientColors.first, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to add',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryCard(
    ColorScheme cs,
    int activeCount,
    int completedCount,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Material(
          color: TorStreamTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/library'),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TorStreamTheme.seedColor.withValues(alpha: 0.15),
                          TorStreamTheme.seedColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: TorStreamTheme.seedColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Library',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _countBadge(
                              '$activeCount active',
                              TorStreamTheme.seedColor,
                            ),
                            const SizedBox(width: 8),
                            _countBadge(
                              '$completedCount completed',
                              TorStreamTheme.accentGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TorStreamTheme.seedColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Open',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: TorStreamTheme.seedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _countBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddContentSection(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TorStreamTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TorStreamTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    size: 18,
                    color: TorStreamTheme.seedColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'More ways to add',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _contentTile(
                icon: Icons.content_paste_go_rounded,
                title: 'Paste from Clipboard',
                subtitle: 'Automatically detect magnet links',
                color: TorStreamTheme.seedColor,
                onTap: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final clipText = data?.text;
                  if (clipText != null && clipText.contains('magnet:')) {
                    _addMagnet(context, ref, clipText.trim());
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'No magnet link found in clipboard',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 1, color: TorStreamTheme.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _contentTile(
                  icon: Icons.search_rounded,
                  title: 'Search Torrents',
                  subtitle: 'Find content to stream',
                  color: TorStreamTheme.accentGreen,
                  onTap: () {
                    // Future: integrated search
                  },
                ),
              ),
              const Divider(height: 1, color: TorStreamTheme.dividerColor),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _contentTile(
                  icon: Icons.file_upload_rounded,
                  title: 'Upload Torrent File',
                  subtitle: 'Select a .torrent from your device',
                  color: TorStreamTheme.accentAmber,
                  onTap: () => _pickTorrentFile(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About TorStream',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.25),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TorStream lets you stream torrents instantly without waiting for '
              'the full download. Paste a magnet or upload a .torrent to start watching. '
              'Content is cached temporarily; use the download option to keep files permanently.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.25),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Magnet Dialog ──────────────────────────────────────────────────────────

  void _showMagnetSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Add Magnet Link',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Paste a magnet URL to start streaming instantly.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                )),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: TorStreamTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TorStreamTheme.dividerColor),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'magnet:?xt=urn:btih:...',
                    hintStyle: TextStyle(
                      color: TorStreamTheme.textSecondary.withValues(alpha: 0.4),
                      fontFamily: 'monospace', fontSize: 11,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                      final clipText = data?.text;
                      if (clipText != null && clipText.contains('magnet:')) {
                        controller.text = clipText;
                      }
                      },
                      child: const Text('Paste'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        final magnet = controller.text.trim();
                        if (magnet.isEmpty) return;
                        Navigator.pop(ctx);
                        _addMagnet(context, ref, magnet);
                      },
                      child: const Text('Add & Stream'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Torrent File Picker ───────────────────────────────────────────────────

  Future<void> _pickTorrentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['torrent'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) return;

      await _addTorrentFile(context, ref, bytes, file.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: TorStreamTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _addTorrentFile(
    BuildContext context,
    WidgetRef ref,
    List<int> data,
    String fileName,
  ) async {
    try {
      final id = await addTorrentFile(data: data);
      if (!context.mounted) return;
      final streamSet = ref.read(streamOnlyTorrentIdsProvider);
      ref.read(streamOnlyTorrentIdsProvider.notifier).state = {
        ...streamSet,
        id,
      };
      ref.read(torrentListNotifierProvider.notifier).refresh();

      await TorrentBox.instance.save(
        TorrentModel(
          magnetUri: '',
          title: fileName.replaceAll(RegExp(r'\.torrent$'), ''),
          fileIndex: 0,
          positionMs: 0,
          durationMs: 0,
          lastWatchedAt: DateTime.now().toIso8601String(),
        ),
      );

      _showPostAddSheet(context, ref, id, '');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: TorStreamTheme.accentRed,
          ),
        );
      }
    }
  }

  // ── Shared ─────────────────────────────────────────────────────────────────

  Future<void> _addMagnet(
    BuildContext context,
    WidgetRef ref,
    String magnet,
  ) async {
    try {
      final id = await addMagnet(magnetUri: magnet);
      final streamSet = ref.read(streamOnlyTorrentIdsProvider);
      ref.read(streamOnlyTorrentIdsProvider.notifier).state = {
        ...streamSet,
        id,
      };
      ref.read(torrentListNotifierProvider.notifier).refresh();
      try {
        await pauseTorrent(id: id);
      } catch (_) {}
      final encodedMagnet = Uri.encodeQueryComponent(magnet);
      if (context.mounted) {
        context.push('/player/$id/0?streamOnly=true&magnet=$encodedMagnet');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: TorStreamTheme.accentRed,
          ),
        );
      }
    }
  }

  void _showPostAddSheet(
    BuildContext context,
    WidgetRef ref,
    BigInt torrentId,
    String magnetUri,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TorStreamTheme.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: TorStreamTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Added Successfully',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stream now or download in background',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Stream Now'),
              onPressed: () {
                Navigator.pop(ctx);
                if (magnetUri.isNotEmpty) {
                  final encoded = Uri.encodeQueryComponent(magnetUri);
                  context.push(
                    '/player/$torrentId/0?streamOnly=true&magnet=$encoded',
                  );
                } else {
                  context.push('/player/$torrentId/0');
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download in Background'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
