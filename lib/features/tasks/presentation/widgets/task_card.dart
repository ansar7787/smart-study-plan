import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCountdown() {
    if (widget.task.isCompleted) return 'Completed';

    final start = widget.task.startDate ?? widget.task.createdAt;
    final end = widget.task.dueDate;

    if (_now.isBefore(start)) {
      final diff = start.difference(_now);
      return 'Starts in: ${_formatDuration(diff)}';
    } else if (_now.isBefore(end)) {
      final diff = end.difference(_now);
      return 'Time Left: ${_formatDuration(diff)}';
    } else {
      return 'Overdue';
    }
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}d ${d.inHours % 24}h';
    } else if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    } else {
      return '${d.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme);
    final countdownText = _getCountdown();
    final start = widget.task.startDate ?? widget.task.createdAt;
    final isLocked = _now.isBefore(start) && !widget.task.isCompleted;

    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox(),
      secondaryBackground: _SwipeAction(
        color: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
      ),
      confirmDismiss: (_) async {
        widget.onDelete.call();
        return true;
      },
      child: InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // ✅ CUSTOM CHECKBOX
              InkWell(
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot complete task before it starts!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  widget.onToggle();
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.task.isCompleted
                        ? theme.colorScheme.primary
                        : (isLocked
                              ? theme.disabledColor.withValues(alpha: 0.1)
                              : Colors.transparent),
                    border: Border.all(
                      color: widget.task.isCompleted
                          ? theme.colorScheme.primary
                          : (isLocked
                                ? theme.disabledColor.withValues(alpha: 0.3)
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  )),
                      width: 2,
                    ),
                  ),
                  child: widget.task.isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : (isLocked
                            ? Icon(
                                Icons.lock,
                                size: 14,
                                color: theme.disabledColor,
                              )
                            : null),
                ),
              ),
              const SizedBox(width: 16),

              // 📄 CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.task.isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Countdowns Row
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          countdownText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme
                                .colorScheme
                                .primary, // Highlight countdown
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Times
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start: ${DateFormat('MMM d, h:mm a').format(start.toLocal())}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'End:   ${DateFormat('MMM d, h:mm a').format(widget.task.dueDate.toLocal())}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                            fontWeight: _isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _StatusChip(label: _statusText, color: statusColor),
                  ],
                ),
              ),

              // 🔔 REMINDER BUTTON
              if (!widget.task.isCompleted)
                IconButton(
                  tooltip: widget.hasReminder ? 'Reminder set' : 'Add reminder',
                  icon: Icon(
                    widget.hasReminder
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    color: widget.hasReminder
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                    size: 20,
                  ),
                  onPressed: widget.hasReminder ? null : widget.onAddReminder,
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
      widget.task.dueDate.isBefore(DateTime.now()) && !widget.task.isCompleted;

  String get _statusText {
    if (widget.task.isCompleted) return 'Completed';
    if (_isOverdue) return 'Overdue';
    return 'Pending';
  }

  Color _statusColor(ThemeData theme) {
    if (widget.task.isCompleted) return theme.disabledColor;
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
