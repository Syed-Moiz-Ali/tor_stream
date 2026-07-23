import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/player/presentation/player_screen.dart';
import '../features/add_torrent/presentation/add_torrent_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

import '../features/history/presentation/history_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/player/:torrentId/:fileIndex',
      name: 'player',
      builder: (_, state) => PlayerScreen(
        torrentId: BigInt.parse(state.pathParameters['torrentId']!),
        fileIndex: int.parse(state.pathParameters['fileIndex']!),
        isStreamOnly: state.uri.queryParameters['streamOnly'] == 'true',
        magnetUri: state.uri.queryParameters['magnet'] != null
            ? Uri.decodeQueryComponent(state.uri.queryParameters['magnet']!)
            : null,
      ),
    ),
    GoRoute(
      path: '/add-torrent',
      name: 'addTorrent',
      builder: (_, __) => const AddTorrentScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
