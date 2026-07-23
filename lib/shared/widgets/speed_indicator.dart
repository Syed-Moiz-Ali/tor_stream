import 'package:flutter/material.dart';

class SpeedIndicator extends StatelessWidget {
  final int downloadSpeed;
  final int uploadSpeed;
  final bool showLabel;

  const SpeedIndicator({
    super.key,
    required this.downloadSpeed,
    this.uploadSpeed = 0,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _speedChip(
          context,
          icon: Icons.arrow_downward_rounded,
          speed: downloadSpeed,
          color: const Color(0xFF2ECC71),
        ),
        const SizedBox(width: 12),
        _speedChip(
          context,
          icon: Icons.arrow_upward_rounded,
          speed: uploadSpeed,
          color: const Color(0xFF7C6EF8),
        ),
      ],
    );
  }

  Widget _speedChip(
    BuildContext context, {
    required IconData icon,
    required int speed,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final label = _formatSpeed(speed);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '$bytesPerSec B/s';
    if (bytesPerSec < 1048576) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / 1048576).toStringAsFixed(1)} MB/s';
  }
}
