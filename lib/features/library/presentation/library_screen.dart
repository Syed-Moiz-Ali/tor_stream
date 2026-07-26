import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../app/theme.dart';
import '../../home/providers/torrent_list_provider.dart';
import '../../home/presentation/torrent_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final torrentsAsync = ref.watch(torrentListNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cs),
            _buildTabBar(cs),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTorrentList(torrentsAsync, isCompletedTab: false),
                  _buildTorrentList(torrentsAsync, isCompletedTab: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, size: 20,
              color: cs.onSurface.withValues(alpha: 0.6)),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Text('My Library', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: cs.onSurface, letterSpacing: -0.3,
          )),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.history_rounded, size: 20,
              color: cs.onSurface.withValues(alpha: 0.6)),
            tooltip: 'Watch History',
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, size: 20,
              color: cs.onSurface.withValues(alpha: 0.6)),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme cs) {
    final torrentsAsync = ref.watch(torrentListNotifierProvider);
    final downloadingCount = torrentsAsync.valueOrNull?.where((t) => !t.isCompleted).length ?? 0;
    final downloadedCount = torrentsAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: TorStreamTheme.seedColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: TorStreamTheme.seedColor,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.downloading_rounded, size: 14),
                const SizedBox(width: 6),
                Text('Downloading  $downloadingCount'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 14),
                const SizedBox(width: 6),
                Text('Downloaded  $downloadedCount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorrentList(AsyncValue<List<TorrentState>> torrentsAsync, {required bool isCompletedTab}) {
    final cs = Theme.of(context).colorScheme;
    return torrentsAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: TorStreamTheme.seedColor),
            ),
            const SizedBox(height: 12),
            Text('Loading...', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
          ],
        ),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: cs.error.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text('Connection Error', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.read(torrentListNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (torrents) {
        final filtered = torrents.where((t) => isCompletedTab ? t.isCompleted : !t.isCompleted).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TorStreamTheme.seedColor.withValues(alpha: 0.1),
                          TorStreamTheme.seedColor.withValues(alpha: 0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      isCompletedTab ? Icons.check_circle_outline_rounded : Icons.downloading_rounded,
                      size: 32,
                      color: isCompletedTab
                          ? TorStreamTheme.accentGreen.withValues(alpha: 0.4)
                          : TorStreamTheme.seedColor.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCompletedTab ? 'Nothing downloaded yet' : 'No active torrents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCompletedTab
                        ? 'Completed downloads appear here'
                        : 'Tap + to add your first torrent',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: filtered.length,
          itemBuilder: (_, i) => TorrentTile(torrent: filtered[i]),
        );
      },
    );
  }
}
