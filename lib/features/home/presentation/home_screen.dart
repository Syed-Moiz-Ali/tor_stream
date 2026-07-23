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
                    icon: const Icon(Icons.close_rounded),
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
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () => setState(() => _showSearch = true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.history_rounded),
                        tooltip: 'Watch History',
                        onPressed: () => context.push('/history'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded),
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
                    icon: Icon(Icons.downloading_rounded, size: 18),
                    text: 'Downloading',
                  ),
                  Tab(
                    icon: Icon(Icons.check_circle_outline_rounded, size: 18),
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
              elevation: 4,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<FrbSearchResultItem>> searchAsync, {Key? key}) {
    final cs = Theme.of(context).colorScheme;
    return searchAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 28, height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: cs.error.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text('Search failed', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: cs.onSurface.withValues(alpha: 0.15)),
                const SizedBox(height: 12),
                Text('No results found', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
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
          width: 28, height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 44, color: cs.error.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text('Failed to load', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.read(torrentListNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
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
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCompletedTab ? Icons.check_circle_outline_rounded : Icons.downloading_rounded,
                      size: 28, color: cs.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCompletedTab ? 'No completed downloads' : 'No active downloads',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCompletedTab
                        ? 'Completed downloads will appear here'
                        : 'Add a magnet to start streaming',
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.35)),
                  ),
                  if (!isCompletedTab) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.push('/add-torrent'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Torrent'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TorStreamTheme.seedColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.movie_rounded, color: TorStreamTheme.seedColor, size: 20),
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
            style: TextStyle(fontSize: 10, color: TorStreamTheme.seedColor)),
          backgroundColor: TorStreamTheme.seedColor.withValues(alpha: 0.1),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
      ),
    );
  }
}
