import 'package:flutter/material.dart';
import 'dart:math' as math;

class PerformanceGauge extends StatelessWidget {
  final double score; // 0 to 100
  final String label;

  const PerformanceGauge({
    super.key,
    required this.score,
    this.label = 'Productivity Score',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (score > 70 ? Colors.green : Colors.orange).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  score > 70 ? 'Excellent' : 'Good Progress',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: score > 70 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Track
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _GaugePainter(
                    progress: 1.0,
                    color: colors.surfaceContainerHighest,
                    strokeWidth: 16,
                  ),
                ),
                // Progress Track
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _GaugePainter(
                    progress: score / 100,
                    color: colors.primary,
                    strokeWidth: 16,
                    isGradient: true,
                  ),
                ),
                // Score Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toInt().toString(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      '%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getFeedbackText(score),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getFeedbackText(double score) {
    if (score >= 80) {
      return "Fantastic! You're crushing your goals this week. Keep the momentum going! 🔥";
    } else if (score >= 50) {
      return "Good job! You're making steady progress. Push a little harder to reach top performance! 🚀";
    } else if (score > 0) {
      return "Off to a start! Consistency is key. Keep going, small steps matter. 🌱";
    } else {
      return "No tasks completed yet. Let's get started on your first goal! 💪";
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isGradient;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.isGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isGradient) {
      paint.shader = SweepGradient(
        colors: [color.withValues(alpha: 0.1), color],
        stops: const [0.0, 1.0],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        transform: GradientRotation(-math.pi / 2 + (math.pi * 0.2)),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = color;
    }

    // Draw the arc (Semi-circular or 3/4 circular gauge look)
    // We'll go with a 3/4 arc for a more "tachometer" feel
    const startAngle = 3 * math.pi / 4;
    const sweepAngle = 3 * math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
