import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../../shared/models/playback_state.dart';

class PlaybackControls extends ConsumerWidget {
  final BigInt torrentId;
  final int fileIndex;

  const PlaybackControls({
    super.key,
    required this.torrentId,
    required this.fileIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(playerProvider((torrentId: torrentId, fileIndex: fileIndex)));
    final playback = streamState.playback;
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playback != null) ...[
          _progressRow(playback, cs),
          const SizedBox(height: 8),
          _timeRow(playback, cs),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, size: 32),
              onPressed: () {},
              color: cs.onSurface,
            ),
            const SizedBox(width: 16),
            _playPauseButton(context, ref, streamState, cs),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 32),
              onPressed: () {},
              color: cs.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  Widget _playPauseButton(BuildContext context, WidgetRef ref, StreamState state, ColorScheme cs) {
    final isPlaying = state.playback?.isPlaying ?? false;

    return Container(
      width: 64,
      height: 64,
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
        icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
        color: Colors.white,
        onPressed: () {
          if (isPlaying) {
            ref.read(playerProvider((torrentId: torrentId, fileIndex: fileIndex)).notifier).pause();
          } else {
            ref.read(playerProvider((torrentId: torrentId, fileIndex: fileIndex)).notifier).play();
          }
        },
      ),
    );
  }

  Widget _progressRow(PlaybackState playback, ColorScheme cs) {
    final progress = playback.duration.inMilliseconds > 0
        ? playback.position.inMilliseconds / playback.duration.inMilliseconds
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6EF8)),
      ),
    );
  }

  Widget _timeRow(PlaybackState playback, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(playback.positionFormatted,
          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
        Text('-${playback.remainingFormatted}',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }
}
