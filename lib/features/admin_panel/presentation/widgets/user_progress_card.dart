import 'package:flutter/material.dart';
import '../../domain/entities/user_progress.dart';

class UserProgressCard extends StatelessWidget {
  final UserProgress progress;

  const UserProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final completionPercent = (progress.completionRate * 100).toInt();
    final isInactive = progress.isInactive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isInactive
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.teal.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    color: isInactive ? Colors.red : Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${progress.userId}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isInactive ? 'Inactive user' : 'Active user',
                        style: TextStyle(
                          fontSize: 12,
                          color: isInactive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                _streakBadge(progress.currentStreak),
              ],
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // PROGRESS BAR
            // --------------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.completionRate,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 8),
            Text('$completionPercent% tasks completed'),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // STATS GRID
            // --------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Subjects', progress.subjectsCount),
                _stat('Tasks', progress.totalTasks),
                _stat('Done', progress.completedTasks),
                _stat('Pending', progress.pendingTasks),
              ],
            ),

            const Divider(height: 32),

            // --------------------------------------------------
            // FOOTER
            // --------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study Time: ${progress.totalStudyMinutes} min',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Last Active: ${_formatDate(progress.lastActiveAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _streakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
