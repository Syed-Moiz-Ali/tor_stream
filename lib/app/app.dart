import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'router.dart';

class TorStreamApp extends ConsumerWidget {
  const TorStreamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TorStream',
      debugShowCheckedModeBanner: false,
      theme: TorStreamTheme.dark(),
      routerConfig: goRouter,
    );
  }
}
