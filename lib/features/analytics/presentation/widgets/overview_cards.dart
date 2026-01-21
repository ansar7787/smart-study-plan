import 'package:flutter/material.dart';
import '../../domain/entities/progress_snapshot.dart';

class OverviewCards extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const OverviewCards({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Completion',
                value: '${snapshot.completionPercentage.toInt()}%',
                subtitle: '${snapshot.completedTasks} tasks done',
                icon: Icons.rocket_launch_rounded,
                colors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewCard(
                title: 'Total Hours',
                value: snapshot.totalStudyHours.toStringAsFixed(1),
                subtitle: 'h spent studying',
                icon: Icons.auto_graph_rounded,
                colors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Sessions',
                value: snapshot.sessionCount.toString(),
                subtitle: 'focused periods',
                icon: Icons.local_fire_department_rounded,
                colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewCard(
                title: 'Overdue',
                value: snapshot.overdueTasks.toString(),
                subtitle: 'needs attention',
                icon: Icons.error_outline_rounded,
                colors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
