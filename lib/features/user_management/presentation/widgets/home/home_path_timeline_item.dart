import 'package:flutter/material.dart';
import 'home_path_step.dart';

class HomePathTimelineItem extends StatelessWidget {
  final HomePathStep step;
  final bool isLast;

  const HomePathTimelineItem({
    super.key,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: step.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(step.icon, color: step.color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: step.color.withValues(alpha: 0.08),
              border: Border.all(color: step.color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(step.subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
