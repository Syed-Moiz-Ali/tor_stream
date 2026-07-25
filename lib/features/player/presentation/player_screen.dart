import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:video_player/video_player.dart';
import '../../../bridge/bridge.dart';
import '../../../shared/torrent_box.dart';
import '../../../app/theme.dart';
import '../providers/player_provider.dart';

// ── Professional Torrent Video Player ──────────────────────────────────────
// Design inspired by VLC, IINA, and Infuse — clean, minimal, gesture-driven.

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

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  // ── Core ──
  VideoPlayerController? _controller;
  bool _startedInit = false;
  bool _videoError = false;
  String? _fileName;

  // ── UI state ──
  bool _fullscreen = false;
  bool _uiVisible = true;
  Timer? _uiTimer;
  late AnimationController _animCtrl;

  // ── Gestures ──
  final GlobalKey _gestureKey = GlobalKey();
  bool _locked = false;
  double _gestureStartVal = 0;
  bool _gestureLeft = false;
  double _gestureDelta = 0;
  bool _gestureActive = false;

  // ── Playback ──
  double _speed = 1.0;
  final List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  int _sleepMins = 0;
  Timer? _sleepTimer;
  int _aspectIdx = 0;
  final List<double> _aspects = [0, 16 / 9, 4 / 3, 1.0];

  double get _rw => MediaQuery.of(context).size.width;
  double get _rh => MediaQuery.of(context).size.height;

  // ── Lifecycle ──
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    Future.microtask(
      () => ref
          .read(
            playerProvider((
              torrentId: widget.torrentId,
              fileIndex: widget.fileIndex,
            )).notifier,
          )
          .init(),
    );
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _sleepTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _savePos();
    _controller?.dispose();
    if (widget.isStreamOnly)
      removeTorrent(id: widget.torrentId, deleteFiles: true);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    _animCtrl.dispose();
    super.dispose();
  }

  void _savePos() {
    if (!mounted || !widget.isStreamOnly || widget.magnetUri == null) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    TorrentBox.instance.savePosition(
      widget.magnetUri!,
      positionMs: _controller!.value.position.inMilliseconds,
      durationMs: _controller!.value.duration.inMilliseconds,
      title: _fileName,
    );
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
    _savePos();
  }

  // ── Orientation ──
  void _enterFullscreen() {
    if (_fullscreen) return;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _fullscreen = true);
    WakelockPlus.enable();
    _showUITemp();
  }

  void _exitFullscreen() {
    if (!_fullscreen) return;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _fullscreen = false;
      _uiVisible = true;
    });
    _animCtrl.forward();
    WakelockPlus.disable();
  }

  void _showUITemp() {
    _uiTimer?.cancel();
    setState(() => _uiVisible = true);
    _animCtrl.forward();
    if (!_locked) {
      _uiTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _uiVisible = false);
          _animCtrl.reverse();
        }
      });
    }
  }

  // ── Init video ──
  void _initVideo(String url) async {
    if (_startedInit || _videoError) return;
    _startedInit = true;
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      if (widget.isStreamOnly && widget.magnetUri != null) {
        final saved = TorrentBox.instance.get(widget.magnetUri!);
        if (saved != null &&
            saved.positionMs > 3000 &&
            saved.durationMs > 0 &&
            saved.positionMs < saved.durationMs - 5000) {
          await c.seekTo(saved.position);
        }
      }
      c.setPlaybackSpeed(_speed);
      setState(() {
        _controller = c;
      });
      _controller!.addListener(_onControllerUpdate);
      _controller!.play();
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  // ── Gesture handler ──
  void _onGestureStart(DragStartDetails d) {
    if (_locked) return;
    _gestureLeft = d.localPosition.dx < _rw * 0.5;
    _gestureStartVal = _controller?.value.volume ?? 0.5;
    _gestureActive = true;
    _gestureDelta = 0;
    _showUITemp();
  }

  void _onGestureUpdate(DragUpdateDetails d) {
    if (_locked || !_gestureActive) return;
    _gestureDelta -= d.delta.dy / _rh * 2;
    _gestureDelta = _gestureDelta.clamp(-1.0, 1.0);
    final val = (_gestureStartVal + _gestureDelta).clamp(0.0, 1.0);
    _controller?.setVolume(val);
    setState(() {});
  }

  void _onGestureEnd(DragEndDetails d) {
    _gestureActive = false;
  }

  String get _gestureLabel {
    final pct = ((_gestureStartVal + _gestureDelta).clamp(0.0, 1.0) * 100)
        .round();
    return '$pct%';
  }

  // ── Speed ──
  void _nextSpeed() {
    final i = (_speeds.indexOf(_speed) + 1) % _speeds.length;
    setState(() => _speed = _speeds[i]);
    _controller?.setPlaybackSpeed(_speed);
    _toast('${_speed}x');
  }

  void _prevSpeed() {
    final i = (_speeds.indexOf(_speed) - 1 + _speeds.length) % _speeds.length;
    setState(() => _speed = _speeds[i]);
    _controller?.setPlaybackSpeed(_speed);
    _toast('${_speed}x');
  }

  // ── Sleep timer ──
  void _toggleSleepTimer() {
    if (_sleepTimer != null) {
      _sleepTimer?.cancel();
      setState(() {
        _sleepTimer = null;
        _sleepMins = 0;
      });
      _toast('Sleep timer off');
      return;
    }
    _showPicker([
      ListTile(
        title: const Text('15 min'),
        leading: const Icon(Icons.timer_outlined),
        onTap: () => _setSleep(15),
      ),
      ListTile(
        title: const Text('30 min'),
        leading: const Icon(Icons.timer_outlined),
        onTap: () => _setSleep(30),
      ),
      ListTile(
        title: const Text('45 min'),
        leading: const Icon(Icons.timer_outlined),
        onTap: () => _setSleep(45),
      ),
      ListTile(
        title: const Text('60 min'),
        leading: const Icon(Icons.timer_outlined),
        onTap: () => _setSleep(60),
      ),
      ListTile(
        title: const Text('End of file'),
        leading: const Icon(Icons.movie_outlined),
        onTap: () {
          Navigator.pop(context);
          _toast('Sleep: end of file');
        },
      ),
    ], 'Sleep Timer');
  }

  void _setSleep(int mins) {
    Navigator.pop(context);
    _sleepTimer?.cancel();
    setState(() => _sleepMins = mins);
    _sleepTimer = Timer(Duration(minutes: mins), () {
      _controller?.pause();
      if (mounted) _toast('Playback paused (sleep timer)');
      setState(() {
        _sleepTimer = null;
        _sleepMins = 0;
      });
    });
    _toast('Sleep: $mins min');
  }

  // ── Toast ──
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _fullscreen ? 100 : 80,
          left: 80,
          right: 80,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  void _showPicker(List<ListTile> tiles, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...tiles,
          ],
        ),
      ),
    );
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(
      playerProvider((
        torrentId: widget.torrentId,
        fileIndex: widget.fileIndex,
      )),
    );
    _fileName ??= st.fileName;

    if (st.streamUrl != null &&
        _controller == null &&
        !_startedInit &&
        !_videoError) {
      _initVideo(st.streamUrl!);
    }

    // Determine target brightness for status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _fullscreen
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    if (_fullscreen) return _buildFullscreen(st);
    return _buildPortrait(st);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PORTRAIT MODE
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildPortrait(StreamState st) {
    final isReady = _controller != null && _controller!.value.isInitialized;
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
          _fileName ?? 'Stream',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [if (isReady) _speedChip()],
      ),
      body: Column(
        children: [
          Expanded(
            child: st.error != null
                ? _errorView(st.error!)
                : st.isInitialized
                ? _videoView(st)
                : _loadingView(st),
          ),
          if (isReady) _controlBar(),
        ],
      ),
    );
  }

  Widget _videoView(StreamState st) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return _loadingView(st);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _effectiveAspect(),
            child: VideoPlayer(_controller!),
          ),
        ),
        if (_controller!.value.isBuffering) _bufferingBadge(),
        if (_speed != 1.0)
          Positioned(
            bottom: 8,
            right: 8,
            child: _badge('${_speed}x', TorStreamTheme.seedColor),
          ),
        if (_sleepMins > 0)
          Positioned(
            top: 8,
            left: 8,
            child: _badge('$_sleepMins\u2009m', TorStreamTheme.accentAmber),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBtn(Icons.fullscreen_rounded, 18, _enterFullscreen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _controlBar() {
    final c = _controller!;
    if (!c.value.isInitialized) return const SizedBox.shrink();
    final pos = c.value.position;
    final dur = c.value.duration;
    final buffered = c.value.buffered.isNotEmpty
        ? c.value.buffered.last.end
        : Duration.zero;
    final playing = c.value.isPlaying;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          _seekBar(pos, dur, buffered, (d) => c.seekTo(d)),
          const SizedBox(height: 8),
          // Controls row
          Row(
            children: [
              _txt(_fmt(pos), 11),
              const Spacer(),
              _ctrlBtn(Icons.replay_10_rounded, 22, () {
                final t = Duration(
                  seconds: (pos.inSeconds - 10).clamp(0, dur.inSeconds),
                );
                c.seekTo(t);
              }),
              const SizedBox(width: 28),
              _playBtn(playing, 52, () {
                playing ? c.pause() : c.play();
                setState(() {});
              }),
              const SizedBox(width: 28),
              _ctrlBtn(Icons.forward_10_rounded, 22, () {
                final t = Duration(
                  seconds: (pos.inSeconds + 10).min(dur.inSeconds),
                );
                c.seekTo(t);
              }),
              const Spacer(),
              _txt(_fmt(dur), 11),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seekBar(
    Duration pos,
    Duration dur,
    Duration buf,
    void Function(Duration) onSeek,
  ) {
    final maxSec = dur.inSeconds > 0 ? dur.inSeconds.toDouble() : 1.0;
    final val = pos.inSeconds.toDouble().clamp(0.0, maxSec);
    final bufVal = buf.inSeconds.toDouble().clamp(0.0, maxSec);
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: TorStreamTheme.seedColor,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
        overlayColor: TorStreamTheme.seedColor.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          LinearProgressIndicator(
            value: bufVal / maxSec,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Colors.white24),
            minHeight: 3,
          ),
          Slider(
            value: val,
            min: 0,
            max: maxSec,
            onChanged: (v) => onSeek(Duration(seconds: v.toInt())),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FULLSCREEN MODE — VLC-Style
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildFullscreen(StreamState st) {
    final isReady = _controller != null && _controller!.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        key: _gestureKey,
        onTap: _showUITemp,
        onVerticalDragStart: _onGestureStart,
        onVerticalDragUpdate: _onGestureUpdate,
        onVerticalDragEnd: _onGestureEnd,
        child: Stack(
          children: [
            // Video layer
            Center(
              child: isReady
                  ? AspectRatio(
                      aspectRatio: _effectiveAspect(),
                      child: VideoPlayer(_controller!),
                    )
                  : const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: TorStreamTheme.seedColor,
                      ),
                    ),
            ),

            // Lock overlay
            if (_locked)
              Positioned.fill(
                child: GestureDetector(
                  onDoubleTap: () => setState(() => _locked = false),
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Double-tap to unlock',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Gesture HUD
            if (_gestureActive && !_locked)
              Positioned(
                left: _gestureLeft ? 24 : null,
                right: !_gestureLeft ? 24 : null,
                top: _rh * 0.3,
                child: AnimatedOpacity(
                  opacity: _gestureActive ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _gestureLeft
                              ? Icons.brightness_medium_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _gestureLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Buffering
            if (isReady && _controller!.value.isBuffering)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(child: _bufferingBadge()),
              ),

            // Sleep indicator
            if (_sleepMins > 0 && _uiVisible)
              Positioned(
                top: 60,
                left: 16,
                child: _badge(
                  'Sleep: $_sleepMins\u2009m',
                  TorStreamTheme.accentAmber,
                ),
              ),

            // TOP BAR
            if (_uiVisible && !_locked)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          _exitFullscreen();
                          context.pop();
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _fileName ?? 'Stream',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Speed down/up
                      IconButton(
                        icon: Text(
                          '${_speed}x',
                          style: const TextStyle(
                            color: TorStreamTheme.seedColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _nextSpeed,
                        onLongPress: _prevSpeed,
                      ),
                      _iconBtn(
                        Icons.timer_outlined,
                        20,
                        _toggleSleepTimer,
                        color: _sleepMins > 0
                            ? TorStreamTheme.accentAmber
                            : Colors.white70,
                      ),
                      _iconBtn(Icons.crop_original_rounded, 20, () {
                        setState(
                          () => _aspectIdx = (_aspectIdx + 1) % _aspects.length,
                        );
                        _toast(['Default', '16:9', '4:3', 'Fill'][_aspectIdx]);
                      }),
                      _iconBtn(
                        _locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                        20,
                        () => setState(() => _locked = !_locked),
                        color: _locked
                            ? TorStreamTheme.accentAmber
                            : Colors.white70,
                      ),
                      _iconBtn(
                        Icons.fullscreen_exit_rounded,
                        20,
                        _exitFullscreen,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),

            // BOTTOM BAR
            if (_uiVisible && !_locked && isReady)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _fullscreenControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fullscreenControls() {
    final c = _controller!;
    final pos = c.value.position;
    final dur = c.value.duration;
    final playing = c.value.isPlaying;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          _seekBar(
            pos,
            dur,
            c.value.buffered.isNotEmpty
                ? c.value.buffered.last.end
                : Duration.zero,
            (d) => c.seekTo(d),
          ),
          const SizedBox(height: 16),
          // Center play button + time
          Row(
            children: [
              _txt(_fmt(pos), 12),
              const Spacer(),
              _ctrlBtn(Icons.replay_10_rounded, 28, () {
                c.seekTo(
                  Duration(
                    seconds: (pos.inSeconds - 10).clamp(0, dur.inSeconds),
                  ),
                );
              }),
              const SizedBox(width: 40),
              _playBtn(playing, 64, () {
                playing ? c.pause() : c.play();
                setState(() {});
              }),
              const SizedBox(width: 40),
              _ctrlBtn(Icons.forward_10_rounded, 28, () {
                c.seekTo(
                  Duration(seconds: (pos.inSeconds + 10).min(dur.inSeconds)),
                );
              }),
              const Spacer(),
              _txt(_fmt(dur), 12),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═════════════════════════════════════════════════════════════════════════
  Widget _ctrlBtn(IconData icon, double size, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: size, color: Colors.white),
      splashRadius: 24,
      onPressed: onTap,
    );
  }

  Widget _playBtn(bool playing, double size, VoidCallback onTap) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [TorStreamTheme.seedColor, Color(0xFF6A5ACD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: TorStreamTheme.seedColor.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: size * 0.5,
          color: Colors.white,
        ),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  Widget _iconBtn(
    IconData icon,
    double size,
    VoidCallback onTap, {
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: size, color: color ?? Colors.white70),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      onPressed: onTap,
    );
  }

  Widget _txt(String s, double size) {
    return Text(
      s,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: size,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _speedChip() {
    return GestureDetector(
      onTap: _nextSpeed,
      onLongPress: _prevSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: TorStreamTheme.seedColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${_speed}x',
          style: const TextStyle(
            color: TorStreamTheme.seedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _bufferingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TorStreamTheme.seedColor.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TorStreamTheme.seedColor,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Buffering',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _errorView(String? err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: TorStreamTheme.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: TorStreamTheme.accentRed,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Playback Error',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              err ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingView(StreamState st) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: TorStreamTheme.seedColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Buffering...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  double _effectiveAspect() {
    if (_controller == null || !_controller!.value.isInitialized) return 16 / 9;
    final src = _controller!.value.aspectRatio;
    if (_aspectIdx == 0) return src;
    return _aspects[_aspectIdx];
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0)
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

extension on int {
  int min(int other) => this < other ? this : other;
}
