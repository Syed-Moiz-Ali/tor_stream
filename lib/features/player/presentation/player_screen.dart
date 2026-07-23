import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/player_provider.dart';
import 'playback_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final BigInt torrentId;
  final int fileIndex;

  const PlayerScreen({
    super.key,
    required this.torrentId,
    required this.fileIndex,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).init();
    });
  }

  @override
  void dispose() {
    ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Stream #${widget.torrentId}',
          style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: streamState.error != null
                  ? _errorView(cs, streamState.error!)
                  : streamState.isInitialized
                      ? _videoPlaceholder(cs)
                      : const CircularProgressIndicator(color: Color(0xFF7C6EF8)),
            ),
          ),
          _controlsSection(cs, streamState),
        ],
      ),
    );
  }

  Widget _videoPlaceholder(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.black,
          child: Center(
            child: Icon(Icons.movie_rounded,
              size: 80, color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Streaming via Rust Engine',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 8),
        Text('Android Media3 + JNI Bridge',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
      ],
    );
  }

  Widget _controlsSection(ColorScheme cs, StreamState streamState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
        ),
      ),
      child: PlaybackControls(
        torrentId: widget.torrentId,
        fileIndex: widget.fileIndex,
      ),
    );
  }

  Widget _errorView(ColorScheme cs, String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
          const SizedBox(height: 16),
          Text(error,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
