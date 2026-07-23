import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../shared/services/stream_store.dart';
import '../providers/player_provider.dart';
import 'playback_controls.dart';
import '../../home/providers/torrent_list_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final BigInt torrentId;
  final int fileIndex;
  final bool isStreamOnly;
  /// The original magnet URI — only set for stream-only sessions.
  /// Used to update StreamStore (position, title) and to re-add the torrent
  /// on resume when the app was killed between sessions.
  final String? magnetUri;

  const PlayerScreen({
    super.key,
    required this.torrentId,
    required this.fileIndex,
    this.isStreamOnly = false,
    this.magnetUri,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitializingVideo = false;
  bool _hasVideoError = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Save the current position to StreamStore (stream-only) or nothing
  /// (download mode is handled by a separate download history store).
  void _savePosition() {
    if (!widget.isStreamOnly || widget.magnetUri == null) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    final streamState = ref.read(
      playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)),
    );
    StreamStore.instance.savePosition(
      widget.magnetUri!,
      positionMs: _controller!.value.position.inMilliseconds,
      durationMs: _controller!.value.duration.inMilliseconds,
      title: streamState.fileName,
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(playerProvider(
              (torrentId: widget.torrentId, fileIndex: widget.fileIndex))
              .notifier)
          .init();
    });
  }

  void _onControllerUpdated() {
    if (!mounted) return;
    setState(() {});
    _savePosition();
  }

  void _initVideoController(String url) async {
    if (_controller != null || _isInitializingVideo || _hasVideoError) return;
    _isInitializingVideo = true;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) return;

      // Restore saved position for stream-only mode from Hive.
      if (widget.isStreamOnly && widget.magnetUri != null) {
        final saved = StreamStore.instance.get(widget.magnetUri!);
        if (saved != null &&
            saved.positionMs > 3000 &&
            saved.durationMs > 0 &&
            saved.positionMs < saved.durationMs - 5000) {
          await controller.seekTo(saved.position);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resumed from ${saved.formattedPosition}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF7C6EF8),
            ),
          );
        }
      }

      setState(() {
        _controller = controller;
        _controller!.addListener(_onControllerUpdated);
        _controller!.play();
      });
    } catch (_) {
      if (mounted) setState(() => _hasVideoError = true);
    } finally {
      _isInitializingVideo = false;
    }
  }

  @override
  void dispose() {
    // Save final position before tearing down.
    _savePosition();

    _controller?.removeListener(_onControllerUpdated);
    _controller?.dispose();

    if (widget.isStreamOnly) {
      // Remove torrent from librqbit AND delete all temp chunk files from disk.
      // The magnet URI is already safely stored in Hive for future resume.
      ref.read(
        removeTorrentProvider((id: widget.torrentId, deleteFiles: true)),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)));
    final cs = Theme.of(context).colorScheme;

    if (streamState.streamUrl != null && _controller == null && !_isInitializingVideo && !_hasVideoError) {
      _initVideoController(streamState.streamUrl!);
    }

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
                      ? _buildPlayerView(cs, streamState)
                      : _initialBufferingView(cs),
            ),
          ),
          _controlsSection(cs, streamState),
        ],
      ),
    );
  }

  Widget _buildPlayerView(ColorScheme cs, StreamState streamState) {
    if (_controller != null && _controller!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (_controller!.value.isBuffering)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF7C6EF8).withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C6EF8)),
                  ),
                  SizedBox(width: 10),
                  Text('Buffering Chunk...',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C6EF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stream_rounded, size: 56, color: Color(0xFF7C6EF8)),
          const SizedBox(height: 12),
          const Text('Rust Stream Server Active',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (streamState.streamUrl != null)
            SelectableText(
              streamState.streamUrl!,
              style: const TextStyle(color: Color(0xFF7C6EF8), fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile('Status', streamState.playback?.status ?? 'active'),
              _infoTile('Download', '${((streamState.playback?.downloadSpeed ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB/s'),
              _infoTile('Buffer', '${((streamState.playback?.bufferProgress ?? 0) * 100).toInt()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
        controller: _controller,
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

  Widget _initialBufferingView(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: Color(0xFF7C6EF8),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Connecting & Buffering Stream...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching initial pieces from BitTorrent peers...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
