import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpcoming = reminder.status == ReminderStatus.upcoming;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          // STATUS BAR
          Container(
            width: 6,
            height: 48,
            decoration: BoxDecoration(
              color: isUpcoming
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'EEE, MMM d • hh:mm a',
                  ).format(reminder.reminderTime),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    _Chip('${reminder.minutesBefore} min'),
                    _Chip(reminder.reminderType),
                  ],
                ),
              ],
            ),
          ),

          // TOGGLE
          Switch(value: reminder.isActive, onChanged: onToggle),
        ],
      ),
    );
  }
}

// ---------------- SMALL CHIP ----------------

class _Chip extends StatelessWidget {
  final String label;

  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
