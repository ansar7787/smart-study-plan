import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddReminder;
  final bool hasReminder;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.hasReminder,
    this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox(),
      secondaryBackground: _SwipeAction(
        color: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
      ),
      confirmDismiss: (_) async {
        onDelete.call();
        return true;
      },
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              // ✅ TOGGLE (COMPLETE / UNCOMPLETE)
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(width: 14),

              // 📄 CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Due • ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _isOverdue
                            ? Colors.red
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _StatusChip(label: _statusText, color: statusColor),
                  ],
                ),
              ),

              // 🔔 REMINDER BUTTON
              IconButton(
                tooltip: hasReminder ? 'Reminder already set' : 'Add reminder',
                icon: Icon(
                  hasReminder
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: hasReminder
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                onPressed: hasReminder ? null : onAddReminder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS HELPERS
  // ---------------------------------------------------------------------------

  bool get _isOverdue =>
      task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

  String get _statusText {
    if (task.isCompleted) return 'Completed';
    if (_isOverdue) return 'Overdue';
    return 'Pending';
  }

  Color _statusColor(ThemeData theme) {
    if (task.isCompleted) return theme.disabledColor;
    if (_isOverdue) return Colors.red;
    return theme.colorScheme.primary;
  }
}

/* -------------------------------------------------------------------------- */
/*                               SWIPE ACTION                                 */
/* -------------------------------------------------------------------------- */

class _SwipeAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               STATUS CHIP                                  */
/* -------------------------------------------------------------------------- */

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
