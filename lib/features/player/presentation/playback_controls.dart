import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../bridge/generated/types.dart';
import '../../../shared/models/torrent_state.dart';
import '../../home/providers/torrent_list_provider.dart';
import '../providers/player_provider.dart';

class PlaybackControls extends ConsumerStatefulWidget {
  final BigInt torrentId;
  final int fileIndex;
  final VideoPlayerController? controller;

  const PlaybackControls({
    super.key,
    required this.torrentId,
    required this.fileIndex,
    this.controller,
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
        infoHash: '',
        name: '',
        status: FrbTorrentStatus.downloading,
        progress: 0.0,
        downloadSpeed: 0,
        uploadSpeed: 0,
        totalSize: 0,
        downloaded: 0,
        numPeers: 0,
        savePath: '',
        addedAtMs: 0,
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
        // Chunk Stream Info Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stream_rounded, size: 14, color: Color(0xFF7C6EF8)),
                  const SizedBox(width: 6),
                  Text(
                    'Chunk Stream: $percentLoaded% Downloaded',
                    style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                activeTorrent.formattedSpeed,
                style: const TextStyle(fontSize: 11, color: Color(0xFF2ECC71), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Interactive Slider Seekbar
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF7C6EF8),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: const Color(0xFF7C6EF8),
            overlayColor: const Color(0xFF7C6EF8).withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: currentSeconds,
            min: 0.0,
            max: maxSeconds,
            onChanged: (val) {
              setState(() {
                _dragValue = val;
              });
            },
            onChangeEnd: (val) {
              setState(() {
                _dragValue = null;
              });
              final targetDuration = Duration(seconds: val.toInt());
              if (controller != null && controller.value.isInitialized) {
                controller.seekTo(targetDuration);
              } else {
                ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(targetDuration);
              }
            },
          ),
        ),

        // Time Row (Position / Duration)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(seconds: currentSeconds.toInt())),
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
              ),
              Text(
                duration > Duration.zero ? _formatDuration(duration) : '--:--',
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Controls Row: -10s, Play/Pause, +10s
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10_rounded, size: 36),
              color: Colors.white,
              onPressed: () {
                final target = Duration(seconds: (position.inSeconds - 10).clamp(0, maxSeconds.toInt()));
                if (controller != null && controller.value.isInitialized) {
                  controller.seekTo(target);
                } else {
                  ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(target);
                }
              },
            ),
            const SizedBox(width: 24),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C6EF8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C6EF8).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 34),
                color: Colors.white,
                onPressed: () {
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
                },
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.forward_10_rounded, size: 36),
              color: Colors.white,
              onPressed: () {
                final target = Duration(seconds: (position.inSeconds + 10).clamp(0, maxSeconds.toInt()));
                if (controller != null && controller.value.isInitialized) {
                  controller.seekTo(target);
                } else {
                  ref.read(playerProvider((torrentId: widget.torrentId, fileIndex: widget.fileIndex)).notifier).seek(target);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
