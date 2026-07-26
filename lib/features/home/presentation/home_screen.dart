import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import 'package:tor_stream/shared/models/torrent_state.dart';
import '../../../app/theme.dart';
import '../providers/torrent_list_provider.dart';
import '../../search/providers/search_provider.dart';
import 'torrent_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearch = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final torrentsAsync = ref.watch(torrentListNotifierProvider);
    final searchQuery = _searchController.text.trim();
    final searchAsync = _showSearch && searchQuery.isNotEmpty
        ? ref.watch(searchResultsProvider(searchQuery))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search torrents, movies...',
                  hintStyle: TextStyle(color: TorStreamTheme.textSecondary.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('TorStream'),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showSearch
                ? IconButton(
                    key: const ValueKey('close'),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _showSearch = false;
                        _searchController.clear();
                      });
                      _searchFocusNode.unfocus();
                    },
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 20),
                        onPressed: () => setState(() => _showSearch = true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.history_rounded, size: 20),
                        tooltip: 'Watch History',
                        onPressed: () => context.push('/history'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 20),
                        tooltip: 'Settings',
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
          ),
        ],
        bottom: !_showSearch
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.downloading_rounded, size: 16),
                    text: 'Downloading',
                  ),
                  Tab(
                    icon: Icon(Icons.check_circle_outline_rounded, size: 16),
                    text: 'Downloaded',
                  ),
                ],
              )
            : null,
      ),
      body: _showSearch && searchQuery.isNotEmpty
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildSearchResults(searchAsync!, key: ValueKey('search_$searchQuery')),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTorrentList(torrentsAsync, isCompletedTab: false),
                _buildTorrentList(torrentsAsync, isCompletedTab: true),
              ],
            ),
      floatingActionButton: _showSearch
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/add-torrent'),
              backgroundColor: TorStreamTheme.seedColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<FrbSearchResultItem>> searchAsync, {Key? key}) {
    final cs = Theme.of(context).colorScheme;
    return searchAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.0, color: TorStreamTheme.seedColor),
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 36, color: cs.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text('Search failed', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
                const SizedBox(height: 12),
                Text('No results found', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: results.length,
          itemBuilder: (_, i) => _SearchResultTile(result: results[i]),
        );
      },
    );
  }

  Widget _buildTorrentList(AsyncValue<List<TorrentState>> torrentsAsync, {required bool isCompletedTab}) {
    final cs = Theme.of(context).colorScheme;
    return torrentsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.0, color: TorStreamTheme.seedColor),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 40, color: cs.error.withValues(alpha: 0.7)),
              const SizedBox(height: 14),
              Text('Failed to load', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.read(torrentListNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (torrents) {
        final filtered = torrents.where((t) => isCompletedTab ? t.isCompleted : !t.isCompleted).toList();

        if (filtered.isEmpty) {
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
                    child: Icon(
                      isCompletedTab ? Icons.check_circle_outline_rounded : Icons.downloading_rounded,
                      size: 26, color: cs.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isCompletedTab ? 'No completed downloads' : 'No active downloads',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompletedTab
                        ? 'Completed downloads will appear here'
                        : 'Add a magnet to start streaming',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                  if (!isCompletedTab) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/add-torrent'),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Torrent'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (_, i) => TorrentTile(torrent: filtered[i]),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final FrbSearchResultItem result;

  const _SearchResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TorStreamTheme.seedColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.movie_rounded, color: TorStreamTheme.seedColor, size: 18),
        ),
        title: Text(
          result.title.isNotEmpty ? result.title : 'Torrent #${result.torrentId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          'File: ${result.fileName}',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        trailing: Chip(
          label: Text(result.category,
            style: const TextStyle(fontSize: 10, color: TorStreamTheme.seedColor)),
          backgroundColor: TorStreamTheme.seedColor.withValues(alpha: 0.1),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
      ),
    );
  }
}
