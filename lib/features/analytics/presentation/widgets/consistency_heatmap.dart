import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class ConsistencyHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;

  const ConsistencyHeatmap({super.key, required this.datasets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Defines the color intensity buckets
    final colorsets = {
      1: isDark ? Colors.teal.withValues(alpha: 0.2) : Colors.teal[50]!,
      30: isDark ? Colors.teal.withValues(alpha: 0.4) : Colors.teal[100]!,
      60: isDark ? Colors.teal.withValues(alpha: 0.6) : Colors.teal[300]!,
      120: isDark ? Colors.teal.withValues(alpha: 0.8) : Colors.teal[500]!,
      180: isDark ? Colors.teal : Colors.teal[700]!,
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consistency Heatmap',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your study intensity over the last few months',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            HeatMap(
              datasets: datasets,
              colorMode: ColorMode.opacity,
              colorsets: colorsets,
              defaultColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              textColor: theme.textTheme.bodyMedium?.color,
              showColorTip: false, // Cleaner look
              onClick: (value) {
                // Potential interactivity later
              },
              startDate: DateTime.now().subtract(const Duration(days: 80)),
              endDate: DateTime.now(),
              margin: const EdgeInsets.all(4),
              size: 20, // Smaller blocks for Github style
              fontSize: 12,
              scrollable: true, // Allow scrolling if it overflows
            ),
          ],
        ),
      ),
    );
  }
}
