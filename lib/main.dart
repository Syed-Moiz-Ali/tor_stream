import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'bridge/bridge.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'shared/torrent_box.dart';
import 'shared/services/stream_store.dart';
import 'shared/services/foreground_service.dart';
import 'shared/services/resilience_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TorrentBox.instance.init();
  await StreamStore.instance.init();
  await RustLib.init();

  final dir = await getApplicationDocumentsDirectory();

  await initializeTorrentEngine(config: FrbEngineConfig(
    downloadDir: dir.path,
    dataDir: dir.path,
    listenPort: 6881,
    maxConnections: 200,
    uploadRateLimit: 0,
    downloadRateLimit: 0,
    dhtEnabled: true,
    lsdEnabled: true,
    upnpEnabled: true,
    natpmpEnabled: true,
    anonymousMode: false,
    cacheSizeMb: 1024,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TorStreamApp()));
}

class TorStreamApp extends ConsumerStatefulWidget {
  const TorStreamApp({super.key});

  @override
  ConsumerState<TorStreamApp> createState() => _TorStreamAppState();
}

class _TorStreamAppState extends ConsumerState<TorStreamApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resilienceServiceProvider).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final activeCount = ref.read(activeTorrentCountProvider);
      if (activeCount > 0) {
        ForegroundService.start();
        ref.read(foregroundServiceProvider).startMonitoring();
      }
    } else if (state == AppLifecycleState.resumed) {
      ref.read(foregroundServiceProvider).stopMonitoring();
      ForegroundService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TorStream',
      debugShowCheckedModeBanner: false,
      theme: TorStreamTheme.dark(),
      routerConfig: goRouter,
    );
  }
}
