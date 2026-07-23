import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/torrent_box.dart';
import '../../../app/theme.dart';
import '../providers/player_provider.dart';
import 'playback_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final BigInt torrentId;
  final int fileIndex;
  final bool isStreamOnly;
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
  String? _fileName;
  bool _isFullScreen = false;
  bool _showOverlay = true;
  Timer? _overlayTimer;

  void _savePosition() {
    if (!widget.isStreamOnly || widget.magnetUri == null) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    TorrentBox.instance.savePosition(
      widget.magnetUri!,
      positionMs: _controller!.value.position.inMilliseconds,
      durationMs: _controller!.value.duration.inMilliseconds,
      title: _fileName,
    );
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _isFullScreen = true);
    _startOverlayTimer();
  }

  void _exitFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFullScreen = false;
      _showOverlay = true;
    });
    _overlayTimer?.cancel();
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isFullScreen) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void _onTapOverlay() {
    if (_isFullScreen) {
      setState(() => _showOverlay = !_showOverlay);
      if (_showOverlay) _startOverlayTimer();
    }
  }

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

      if (widget.isStreamOnly && widget.magnetUri != null) {
        final saved = TorrentBox.instance.get(widget.magnetUri!);
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
              backgroundColor: TorStreamTheme.seedColor,
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
    _overlayTimer?.cancel();
    if (widget.isStreamOnly && widget.magnetUri != null) {
      _savePosition();
    }
    _controller?.removeListener(_onControllerUpdated);
    _controller?.dispose();
    if (widget.isStreamOnly) {
      removeTorrent(id: widget.torrentId, deleteFiles: true);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)));
    _fileName = streamState.fileName;
    final cs = Theme.of(context).colorScheme;

    if (widget.isStreamOnly && widget.magnetUri != null && _fileName != null && _fileName != 'Loading…') {
      final saved = TorrentBox.instance.get(widget.magnetUri!);
      if (saved != null && saved.title == 'Loading…') {
        saved.title = _fileName!;
        TorrentBox.instance.save(saved);
      }
    }

    if (streamState.streamUrl != null && _controller == null && !_isInitializingVideo && !_hasVideoError) {
      _initVideoController(streamState.streamUrl!);
    }

    if (_isFullScreen) {
      return _fullScreenLayout(streamState);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _fileName ?? 'Stream #${widget.torrentId}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: streamState.error != null
                ? _errorView(cs, streamState.error!)
                : streamState.isInitialized
                    ? _buildPlayerView(streamState)
                    : _initialBufferingView(),
          ),
          _controlsSection(streamState),
        ],
      ),
    );
  }

  Widget _fullScreenLayout(StreamState streamState) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTapOverlay,
        child: Stack(
          children: [
            Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3, color: TorStreamTheme.seedColor),
                    ),
            ),
            if (_showOverlay) ...[
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () {
                          _exitFullScreen();
                          context.pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fileName ?? 'Stream',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                        onPressed: _toggleFullScreen,
                      ),
                    ],
                  ),
                ),
              ),
              if (_controller != null && _controller!.value.isInitialized)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _fullScreenControls(),
                ),
            ],
            if (_controller != null && _controller!.value.isInitialized && _controller!.value.isBuffering)
              Positioned(
                top: 0, bottom: 0, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: TorStreamTheme.seedColor),
                        ),
                        SizedBox(width: 10),
                        Text('Buffering...',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenControls() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: PlaybackControls(
        torrentId: widget.torrentId,
        fileIndex: widget.fileIndex,
        controller: _controller,
        isFullScreen: true,
      ),
    );
  }

  Widget _buildPlayerView(StreamState streamState) {
    if (_controller != null && _controller!.value.isInitialized) {
      return GestureDetector(
        onTap: _isFullScreen ? _onTapOverlay : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            if (!_isFullScreen && _controller!.value.isBuffering)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TorStreamTheme.seedColor.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: TorStreamTheme.seedColor),
                    ),
                    SizedBox(width: 10),
                    Text('Buffering...',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            if (!_isFullScreen)
              Positioned(
                top: 8, right: 8,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 22),
                  onPressed: _toggleFullScreen,
                ),
              ),
          ],
        ),
      );
    }

    return const Center(
      child: SizedBox(
        width: 36, height: 36,
        child: CircularProgressIndicator(strokeWidth: 3, color: TorStreamTheme.seedColor),
      ),
    );
  }

  Widget _controlsSection(StreamState streamState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.95)],
        ),
      ),
      child: PlaybackControls(
        torrentId: widget.torrentId,
        fileIndex: widget.fileIndex,
        controller: _controller,
        isFullScreen: false,
      ),
    );
  }

  Widget _errorView(ColorScheme cs, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: TorStreamTheme.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.error_outline_rounded, size: 28, color: TorStreamTheme.accentRed),
            ),
            const SizedBox(height: 16),
            Text('Stream Error', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _initialBufferingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44, height: 44,
            child: CircularProgressIndicator(strokeWidth: 3, color: TorStreamTheme.seedColor),
          ),
          const SizedBox(height: 24),
          const Text('Connecting & Buffering Stream...',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Fetching pieces from BitTorrent peers',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        ],
      ),
    );
  }
}
