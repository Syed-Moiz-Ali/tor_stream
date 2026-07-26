import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

// Your backend imports
import '../providers/player_provider.dart';

// ── Ultra-Premium Design Tokens ──
const Color _ytRed = Color(0xFFFF0000);
const Color _pureWhite = Color(0xFFFFFFFF);
const Color _white70 = Color(0xB3FFFFFF);
const Color _white30 = Color(0x4DFFFFFF);

enum VideoFit { contain, cover, fill }

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
    with TickerProviderStateMixin {
  // ── Core Engine ──
  VideoPlayerController? _ctrl;
  bool _isInit = false;
  bool _videoError = false;

  // ── UI State ──
  bool _uiVisible = true;
  Timer? _hideTimer;
  bool _isLocked = false;
  double _playbackSpeed = 1.0;
  VideoFit _videoFit = VideoFit.contain;

  // ── MX Gestures (Volume/Brightness/Seek) ──
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _isVerticalDrag = false;
  bool _isLeftZone = false;
  double _dragStartY = 0;
  double _dragStartValue = 0;

  bool _isHorizontalDrag = false;
  double _dragStartX = 0;
  Duration _dragStartPos = Duration.zero;
  Duration _seekDelta = Duration.zero;

  bool _showHud = false;
  Timer? _hudTimer;

  // ── YouTube Double Tap & Long Press ──
  bool _showLeftRipple = false;
  bool _showRightRipple = false;
  int _seekTapCount = 0;
  Timer? _seekTapTimer;

  bool _isHoldingSpeed = false; // Tracks 2x long press

  // ── Animations ──
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _setupHardware();
    _enterImmersive();

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

  Future<void> _setupHardware() async {
    try {
      _brightness = await ScreenBrightness().current;
    } catch (_) {}
    try {
      _volume = await VolumeController().getVolume();
    } catch (_) {}
  }

  void _enterImmersive() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _wakeUI();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hudTimer?.cancel();
    _seekTapTimer?.cancel();
    _ctrl?.removeListener(_onVideoTick);
    _ctrl?.dispose();
    _fadeCtrl.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  void _onVideoTick() {
    if (mounted) setState(() {});
  }

  void _initVideo(String url) async {
    if (_isInit || _videoError) return;
    _isInit = true;
    try {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await _ctrl!.initialize();
      if (!mounted) {
        _ctrl!.dispose();
        return;
      }
      _ctrl!.setPlaybackSpeed(_playbackSpeed);
      _ctrl!.addListener(_onVideoTick);
      _ctrl!.play();
      ref
          .read(
            playerProvider((
              torrentId: widget.torrentId,
              fileIndex: widget.fileIndex,
            )).notifier,
          )
          .play();
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  // ── UI Visibility ──
  void _wakeUI() {
    _hideTimer?.cancel();
    if (!mounted) return;
    setState(() => _uiVisible = true);
    _fadeCtrl.forward();

    if (_isLocked || _isScrubbing || _isHoldingSpeed) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted &&
          !_isHorizontalDrag &&
          !_isVerticalDrag &&
          _ctrl?.value.isPlaying == true) {
        setState(() => _uiVisible = false);
        _fadeCtrl.reverse();
      }
    });
  }

  void _toggleUI() {
    if (_isLocked) return;
    if (_uiVisible) {
      setState(() => _uiVisible = false);
      _fadeCtrl.reverse();
      _hideTimer?.cancel();
    } else {
      _wakeUI();
    }
  }

  void _performSeek(Duration position) {
    if (_ctrl == null) return;
    final clamped = Duration(
      milliseconds: position.inMilliseconds.clamp(
        0,
        _ctrl!.value.duration.inMilliseconds,
      ),
    );
    _ctrl!.seekTo(clamped);
    ref
        .read(
          playerProvider((
            torrentId: widget.torrentId,
            fileIndex: widget.fileIndex,
          )).notifier,
        )
        .seek(clamped);
    _wakeUI();
  }

  // ── Gestures: YouTube Long Press (2x Speed) ──
  void _onLongPressStart(LongPressStartDetails d) {
    if (_isLocked || _ctrl == null || !_ctrl!.value.isInitialized) return;
    // Prevent triggering if touching near the bottom controls
    if (_uiVisible &&
        d.localPosition.dy > MediaQuery.of(context).size.height * 0.7) {
      return;
    }

    HapticFeedback.selectionClick();
    _ctrl!.setPlaybackSpeed(2.0);
    setState(() => _isHoldingSpeed = true);
    _hideTimer?.cancel();
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    _cancelLongPress();
  }

  void _onLongPressCancel() {
    _cancelLongPress();
  }

  void _cancelLongPress() {
    if (!_isHoldingSpeed || _ctrl == null) return;
    _ctrl!.setPlaybackSpeed(_playbackSpeed); // Revert to user's selected speed
    setState(() => _isHoldingSpeed = false);
    _wakeUI();
  }

  // ── Gestures: YouTube Double Tap ──
  void _handleDoubleTap(TapDownDetails d) {
    if (_isLocked || _ctrl == null) return;
    final width = MediaQuery.of(context).size.width;
    final x = d.localPosition.dx;

    // Deadzone in the center 40% to allow for normal single taps to toggle UI
    if (x > width * 0.3 && x < width * 0.7) return;

    HapticFeedback.lightImpact();
    final isLeft = x < width * 0.3;

    _seekTapCount++;
    _seekTapTimer?.cancel();

    setState(() {
      if (isLeft) {
        _showLeftRipple = true;
      } else {
        _showRightRipple = true;
      }
    });

    _performSeek(_ctrl!.value.position + Duration(seconds: isLeft ? -10 : 10));

    _seekTapTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showLeftRipple = false;
          _showRightRipple = false;
          _seekTapCount = 0;
        });
      }
    });
  }

  // ── Gestures: MX Vertical (Volume/Brightness) ──
  void _onVerticalStart(DragStartDetails d) {
    if (_isLocked || _uiVisible || _isHoldingSpeed) return;
    final width = MediaQuery.of(context).size.width;
    final x = d.localPosition.dx;

    if (x > width * 0.4 && x < width * 0.6) return;

    _isVerticalDrag = true;
    _isLeftZone = x < width * 0.5;
    _dragStartY = d.localPosition.dy;
    _dragStartValue = _isLeftZone ? _brightness : _volume;
    _triggerHud();
  }

  void _onVerticalUpdate(DragUpdateDetails d) {
    if (!_isVerticalDrag || _isLocked) return;
    final height = MediaQuery.of(context).size.height;

    final delta = (_dragStartY - d.localPosition.dy) / height * 1.5;
    final newValue = (_dragStartValue + delta).clamp(0.0, 1.0);

    if (_isLeftZone) {
      _brightness = newValue;
      ScreenBrightness().setScreenBrightness(newValue);
    } else {
      _volume = newValue;
      VolumeController().setVolume(newValue);
      _ctrl?.setVolume(newValue);
    }
    setState(() {});
    _triggerHud();
  }

  void _onVerticalEnd(DragEndDetails _) => _isVerticalDrag = false;

  void _triggerHud() {
    setState(() => _showHud = true);
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showHud = false);
    });
  }

  // ── Gestures: MX Horizontal (Seek) ──
  void _onHorizontalStart(DragStartDetails d) {
    if (_isLocked || _ctrl == null || _isHoldingSpeed) return;
    if (d.localPosition.dy > MediaQuery.of(context).size.height * 0.8) return;

    _isHorizontalDrag = true;
    _dragStartX = d.localPosition.dx;
    _dragStartPos = _ctrl!.value.position;
    _seekDelta = Duration.zero;
    _wakeUI();
  }

  void _onHorizontalUpdate(DragUpdateDetails d) {
    if (!_isHorizontalDrag || _isLocked) return;
    final width = MediaQuery.of(context).size.width;

    final deltaSeconds = ((d.localPosition.dx - _dragStartX) / width) * 120.0;
    _seekDelta = Duration(milliseconds: (deltaSeconds * 1000).toInt());
    setState(() {});
  }

  void _onHorizontalEnd(DragEndDetails _) {
    if (_isHorizontalDrag && _ctrl != null) {
      _performSeek(_dragStartPos + _seekDelta);
    }
    setState(() {
      _isHorizontalDrag = false;
      _seekDelta = Duration.zero;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(
      playerProvider((
        torrentId: widget.torrentId,
        fileIndex: widget.fileIndex,
      )),
    );

    if (st.streamUrl != null && _ctrl == null && !_isInit) {
      _initVideo(st.streamUrl!);
    }

    final isReady = _ctrl != null && _ctrl!.value.isInitialized;
    final isBuffering = _ctrl != null && _ctrl!.value.isBuffering;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleUI,
        onDoubleTapDown: _handleDoubleTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onLongPressCancel: _onLongPressCancel,
        onVerticalDragStart: _onVerticalStart,
        onVerticalDragUpdate: _onVerticalUpdate,
        onVerticalDragEnd: _onVerticalEnd,
        onHorizontalDragStart: _onHorizontalStart,
        onHorizontalDragUpdate: _onHorizontalUpdate,
        onHorizontalDragEnd: _onHorizontalEnd,
        child: Stack(
          children: [
            // ── 1. Video Canvas ──
            Positioned.fill(
              child: isReady ? _buildVideoLayer() : const SizedBox.shrink(),
            ),

            // ── 2. Buffering Indicator ──
            if (!isReady || isBuffering)
              const Center(
                child: CircularProgressIndicator(
                  color: _pureWhite,
                  strokeWidth: 2.0,
                ),
              ),

            // ── 3. Gradient Scrims ──
            if (_uiVisible && !_isLocked)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── 4. Edge Ripples (YouTube Double Tap) ──
            if (_showLeftRipple) _buildEdgeRipple(isLeft: true),
            if (_showRightRipple) _buildEdgeRipple(isLeft: false),

            // ── 5. MX Style Frosted HUD (Volume/Brightness) ──
            if (_showHud && !_isLocked && _isVerticalDrag)
              Center(child: _buildFrostedHud()),

            // ── 6. Seek Preview HUD ──
            if (_isHorizontalDrag && isReady) Center(child: _buildSeekHud()),

            // ── 7. 2x Speed Long Press HUD ──
            if (_isHoldingSpeed)
              Positioned(
                top: MediaQuery.of(context).padding.top + 48,
                left: 0,
                right: 0,
                child: Center(child: _buildSpeedHud()),
              ),

            // ── 8. Core UI Controls ──
            FadeTransition(
              opacity: _fadeAnim,
              child: IgnorePointer(
                ignoring: !_uiVisible || _isLocked,
                child: Stack(
                  children: [
                    if (isReady) ...[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildTopBar(st.fileName ?? 'Video'),
                      ),
                      Center(child: _buildCenterControls()),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomBar(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── 9. Locked State Overlay ──
            if (_isLocked)
              Positioned(
                top: 40,
                left: MediaQuery.of(context).padding.left + 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.1),
                      child: IconButton(
                        icon: const Icon(
                          Icons.lock_rounded,
                          color: _pureWhite,
                          size: 24,
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _isLocked = false);
                          _wakeUI();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── UI Components ──

  Widget _buildVideoLayer() {
    Widget videoWidget = VideoPlayer(_ctrl!);
    switch (_videoFit) {
      case VideoFit.cover:
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _ctrl!.value.size.width,
              height: _ctrl!.value.size.height,
              child: videoWidget,
            ),
          ),
        );
      case VideoFit.fill:
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: _ctrl!.value.size.width,
              height: _ctrl!.value.size.height,
              child: videoWidget,
            ),
          ),
        );
      case VideoFit.contain:
        return Center(
          child: AspectRatio(
            aspectRatio: _ctrl!.value.aspectRatio,
            child: videoWidget,
          ),
        );
    }
  }

  Widget _buildTopBar(String title) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _pureWhite,
                size: 32,
              ),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _pureWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.closed_caption_outlined,
                color: _pureWhite,
                size: 24,
              ),
              onPressed: () {}, // Attach your subtitle sheet logic here
            ),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: _pureWhite,
                size: 24,
              ),
              onPressed: _showYouTubeSettingsSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    final playing = _ctrl!.value.isPlaying;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: _pureWhite,
            size: 36,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 48),
        IconButton(
          iconSize: 64,
          icon: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: _pureWhite,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            playing ? _ctrl!.pause() : _ctrl!.play();
            _wakeUI();
          },
        ),
        const SizedBox(width: 48),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: _pureWhite,
            size: 36,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final pos = _ctrl!.value.position;
    final dur = _ctrl!.value.duration;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "${_fmt(pos)} / ${_fmt(dur)}",
                  style: const TextStyle(
                    color: _pureWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.lock_open_rounded,
                    color: _pureWhite,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _isLocked = true;
                      _uiVisible = false;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.aspect_ratio_rounded,
                    color: _pureWhite,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(
                      () => _videoFit =
                          VideoFit.values[(_videoFit.index + 1) %
                              VideoFit.values.length],
                    );
                    _wakeUI();
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildPremiumScrubber(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumScrubber() {
    final durMs = _ctrl!.value.duration.inMilliseconds.toDouble();
    final posMs = _ctrl!.value.position.inMilliseconds.toDouble().clamp(
      0.0,
      durMs > 0 ? durMs : 1.0,
    );
    double bufMs = _ctrl!.value.buffered.isNotEmpty
        ? _ctrl!.value.buffered.last.end.inMilliseconds.toDouble()
        : 0.0;

    return SizedBox(
      height: 20,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: _isScrubbing ? 4.0 : 2.0,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: _isScrubbing ? 8.0 : 6.0,
            elevation: 0,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          activeTrackColor: _ytRed,
          inactiveTrackColor: _white30,
          thumbColor: _ytRed,
          overlayColor: _ytRed.withValues(alpha: 0.2),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            LinearProgressIndicator(
              value: durMs > 0 ? bufMs / durMs : 0,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(_white70),
              minHeight: _isScrubbing ? 4.0 : 2.0,
            ),
            Slider(
              value: posMs,
              min: 0.0,
              max: durMs > 0 ? durMs : 1.0,
              onChangeStart: (_) {
                setState(() => _isScrubbing = true);
                _hideTimer?.cancel();
              },
              onChanged: (val) =>
                  _ctrl!.seekTo(Duration(milliseconds: val.toInt())),
              onChangeEnd: (val) {
                setState(() => _isScrubbing = false);
                _performSeek(Duration(milliseconds: val.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Visual Overlays ──

  Widget _buildEdgeRipple({required bool isLeft}) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.4,
      child: IgnorePointer(
        child: ClipPath(
          clipper: _SemiCircleClipper(isLeft: isLeft),
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isLeft ? 0 : 40,
                  right: isLeft ? 40 : 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLeft)
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: _pureWhite,
                          ),
                        Icon(
                          isLeft
                              ? Icons.play_arrow_rounded
                              : Icons.play_arrow_rounded,
                          color: _pureWhite,
                        ),
                        if (!isLeft)
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: _pureWhite,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_seekTapCount * 10} seconds",
                      style: const TextStyle(
                        color: _pureWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedHud() {
    final isMax = (_isLeftZone ? _brightness : _volume) > 0.5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isLeftZone
                    ? (isMax
                          ? Icons.brightness_high_rounded
                          : Icons.brightness_medium_rounded)
                    : (isMax
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded),
                color: _pureWhite,
                size: 32,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _isLeftZone ? _brightness : _volume,
                    backgroundColor: _white30,
                    valueColor: const AlwaysStoppedAnimation(_pureWhite),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeekHud() {
    final isForward = _seekDelta.inSeconds >= 0;
    final clampedTarget = Duration(
      milliseconds: (_dragStartPos + _seekDelta).inMilliseconds.clamp(
        0,
        _ctrl!.value.duration.inMilliseconds,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${_fmt(clampedTarget)}  [${isForward ? '+' : ''}${_seekDelta.inSeconds}s]",
        style: const TextStyle(
          color: _pureWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSpeedHud() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Playing at 2x speed",
                style: TextStyle(
                  color: _pureWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.fast_forward_rounded, color: _pureWhite, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showYouTubeSettingsSheet() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.speed_rounded,
                color: _pureWhite,
                size: 24,
              ),
              title: const Text(
                "Playback speed",
                style: TextStyle(color: _pureWhite, fontSize: 15),
              ),
              trailing: Text(
                "${_playbackSpeed}x",
                style: const TextStyle(color: _white70, fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _playbackSpeed = _playbackSpeed == 1.0
                      ? 1.5
                      : (_playbackSpeed == 1.5 ? 2.0 : 1.0);
                  _ctrl?.setPlaybackSpeed(_playbackSpeed);
                });
                _wakeUI();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).then((_) => _wakeUI());
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? "${d.inHours}:$m:$s" : "$m:$s";
  }
}

// ── Custom Clipper for Authentic YouTube Ripple ──
class _SemiCircleClipper extends CustomClipper<Path> {
  final bool isLeft;
  _SemiCircleClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isLeft) {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width, size.height / 2, 0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(0, size.height / 2, size.width, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
