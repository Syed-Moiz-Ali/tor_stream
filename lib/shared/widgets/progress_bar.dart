import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showLabel;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor,
    this.progressColor,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: height,
            backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              progressColor ?? _progressColor(clamped, cs),
            ),
          ),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${(clamped * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }

  Color _progressColor(double p, ColorScheme cs) {
    if (p >= 1.0) return const Color(0xFF2ECC71);
    if (p > 0.5) return const Color(0xFF7C6EF8);
    return const Color(0xFFFFB347);
  }
}
