import 'package:flutter/material.dart';
import '../../domain/entities/progress_snapshot.dart';

class OverviewCards extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const OverviewCards({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4, // ✅ FIX: more height
          children: [
            _OverviewCard(
              title: 'Tasks Done',
              value: '${snapshot.completedTasks}/${snapshot.totalTasks}',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _OverviewCard(
              title: 'Study Hours',
              value: snapshot.totalStudyHours.toStringAsFixed(1),
              icon: Icons.timer,
              color: Colors.blue,
            ),
            _OverviewCard(
              title: 'Sessions',
              value: snapshot.sessionCount.toString(),
              icon: Icons.school,
              color: Colors.purple,
            ),
            _OverviewCard(
              title: 'Overdue',
              value: snapshot.overdueTasks.toString(),
              icon: Icons.warning,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: color),

            const Spacer(), // ✅ absorbs free space safely

            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
