import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bridge/bridge.dart';
import 'package:tor_stream/shared/models/torrent_state.dart';
import '../providers/torrent_list_provider.dart';
import '../../search/providers/search_provider.dart';
import 'torrent_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
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
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search torrents, movies, files...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('TorStream'),
        actions: [
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => setState(() => _showSearch = true),
            ),
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                });
              },
            ),
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: _showSearch && searchQuery.isNotEmpty
          ? _buildSearchResults(searchAsync!)
          : _buildTorrentList(torrentsAsync),
      floatingActionButton: _showSearch
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/add-torrent'),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<FrbSearchResultItem>> searchAsync) {
    final cs = Theme.of(context).colorScheme;
    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Search failed: $e', style: TextStyle(color: cs.error)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: cs.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  'No results found',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
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

  Widget _buildTorrentList(AsyncValue<List<TorrentState>> torrentsAsync) {
    final cs = Theme.of(context).colorScheme;
    return torrentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load torrents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$err',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.read(torrentListNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (torrents) {
        if (torrents.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.movie_creation_rounded,
                    size: 64,
                    color: cs.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No torrents yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a magnet link or torrent file to get started',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/add-torrent'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Torrent'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: torrents.length,
          itemBuilder: (_, i) => TorrentTile(torrent: torrents[i]),
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
            color: const Color(0xFF7C6EF8).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.movie_rounded,
            color: Color(0xFF7C6EF8),
            size: 20,
          ),
        ),
        title: Text(
          result.title.isNotEmpty
              ? result.title
              : 'Torrent #${result.torrentId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'File: ${result.fileName}',
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: Chip(
          label: Text(
            result.category,
            style: TextStyle(fontSize: 10, color: const Color(0xFF7C6EF8)),
          ),
          backgroundColor: const Color(0xFF7C6EF8).withValues(alpha: 0.1),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
