import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../bridge/generated/types.dart';
import '../../../shared/models/torrent_state.dart';
import '../../../app/theme.dart';
import '../../home/providers/torrent_list_provider.dart';
import '../providers/player_provider.dart';

class PlaybackControls extends ConsumerStatefulWidget {
  final BigInt torrentId;
  final int fileIndex;
  final VideoPlayerController? controller;
  final bool isFullScreen;

  const PlaybackControls({
    super.key,
    required this.torrentId,
    required this.fileIndex,
    this.controller,
    this.isFullScreen = false,
  });

  @override
  ConsumerState<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends ConsumerState<PlaybackControls> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)));
    final controller = widget.controller;

    final torrents = ref.watch(torrentListNotifierProvider).asData?.value ?? [];
    final activeTorrent = torrents.firstWhere(
      (t) => t.id == widget.torrentId,
      orElse: () => TorrentState(
        id: widget.torrentId,
        infoHash: '', name: '',
        status: FrbTorrentStatus.downloading,
        progress: 0.0, downloadSpeed: 0, uploadSpeed: 0,
        totalSize: 0, downloaded: 0, numPeers: 0,
        savePath: '', addedAtMs: 0,
      ),
    );

    final Duration position = controller?.value.position ?? Duration.zero;
    final Duration duration = controller?.value.duration ?? Duration.zero;

    final double maxSeconds = duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0;
    final double currentSeconds = (_dragValue ?? position.inSeconds.toDouble()).clamp(0.0, maxSeconds);

    final bool isPlaying = controller != null
        ? controller.value.isPlaying
        : (streamState.playback?.isPlaying ?? false);

    final int percentLoaded = (activeTorrent.progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isFullScreen && percentLoaded > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TorStreamTheme.seedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$percentLoaded%',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: TorStreamTheme.seedColor)),
                ),
                const SizedBox(width: 8),
                Text(activeTorrent.formattedSpeed,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: TorStreamTheme.accentGreen)),
              ],
            ),
          ),

        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: TorStreamTheme.seedColor,
            inactiveTrackColor: Colors.white.withValues(alpha: widget.isFullScreen ? 0.15 : 0.12),
            thumbColor: Colors.white,
            overlayColor: TorStreamTheme.seedColor.withValues(alpha: 0.15),
            trackHeight: widget.isFullScreen ? 4 : 3,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: widget.isFullScreen ? 7 : 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: currentSeconds,
            min: 0.0,
            max: maxSeconds,
            onChanged: (val) => setState(() => _dragValue = val),
            onChangeEnd: (val) {
              setState(() => _dragValue = null);
              final target = Duration(seconds: val.toInt());
              if (controller != null && controller.value.isInitialized) {
                controller.seekTo(target);
              } else {
                ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(target);
              }
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.isFullScreen ? 16 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(seconds: currentSeconds.toInt())),
                style: TextStyle(fontSize: widget.isFullScreen ? 12 : 11, color: Colors.white.withValues(alpha: 0.6), fontFamily: 'monospace'),
              ),
              Text(
                duration > Duration.zero ? _formatDuration(duration) : '--:--',
                style: TextStyle(fontSize: widget.isFullScreen ? 12 : 11, color: Colors.white.withValues(alpha: 0.6), fontFamily: 'monospace'),
              ),
            ],
          ),
        ),

        SizedBox(height: widget.isFullScreen ? 12 : 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(Icons.replay_10_rounded, () {
              final target = Duration(seconds: (position.inSeconds - 10).clamp(0, maxSeconds.toInt()));
              if (controller != null && controller.value.isInitialized) {
                controller.seekTo(target);
              } else {
                ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(target);
              }
            }),
            SizedBox(width: widget.isFullScreen ? 40 : 32),
            _playButton(isPlaying, () {
              if (controller != null && controller.value.isInitialized) {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              } else {
                if (isPlaying) {
                  ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).pause();
                } else {
                  ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).play();
                }
              }
            }),
            SizedBox(width: widget.isFullScreen ? 40 : 32),
            _controlButton(Icons.forward_10_rounded, () {
              final target = Duration(seconds: (position.inSeconds + 10).clamp(0, maxSeconds.toInt()));
              if (controller != null && controller.value.isInitialized) {
                controller.seekTo(target);
              } else {
                ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(target);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    final size = widget.isFullScreen ? 36.0 : 32.0;
    return IconButton(
      icon: Icon(icon, size: size),
      color: Colors.white.withValues(alpha: 0.85),
      splashRadius: widget.isFullScreen ? 24 : 22,
      onPressed: onPressed,
    );
  }

  Widget _playButton(bool isPlaying, VoidCallback onPressed) {
    final size = widget.isFullScreen ? 64.0 : 56.0;
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
            color: TorStreamTheme.seedColor.withValues(alpha: widget.isFullScreen ? 0.4 : 0.35),
            blurRadius: widget.isFullScreen ? 18 : 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: widget.isFullScreen ? 34 : 30),
        color: Colors.white,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
