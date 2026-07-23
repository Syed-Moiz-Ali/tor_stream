import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final bool showLabel;
  final bool animated;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor,
    this.showLabel = false,
    this.animated = true,
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
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: animated ? const Duration(milliseconds: 600) : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: height,
              backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(_gradientColor(clamped)),
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
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }

  Color _gradientColor(double p) {
    if (p >= 1.0) return TorStreamTheme.accentGreen;
    if (p > 0.66) return TorStreamTheme.seedColor;
    if (p > 0.33) return const Color(0xFF9B59B6);
    return TorStreamTheme.accentAmber;
  }
}
