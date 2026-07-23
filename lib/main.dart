import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'bridge/bridge.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
