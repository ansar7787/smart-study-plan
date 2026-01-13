import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/study_session.dart';

class SessionCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddReminder;
  final bool hasReminder;

  const SessionCard({
    super.key,
    required this.session,
    required this.hasReminder,
    this.onEdit,
    this.onDelete,
    this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _status;
    final statusColor = _statusColor(theme);

    final timeRange =
        '${DateFormat('h:mm a').format(session.startTime)}'
        ' - ${DateFormat('h:mm a').format(session.endTime)}';

    final duration = session.duration.inMinutes;

    return Dismissible(
      key: ValueKey(session.id),

      // ⬅️ DELETE ONLY
      direction: DismissDirection.endToStart,

      // REQUIRED: background MUST exist if secondaryBackground exists
      background: const SizedBox(),

      secondaryBackground: _SwipeAction(
        color: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
        alignment: Alignment.centerRight,
      ),

      confirmDismiss: (_) async {
        onDelete?.call();
        return true; // allow removal
      },

      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              // STATUS BAR
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$timeRange • $duration min',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    _StatusChip(label: status, color: statusColor),
                  ],
                ),
              ),

              // 🔔 REMINDER ACTION
              IconButton(
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

  // ---------- STATUS LOGIC ----------

  bool get _isPast => session.endTime.isBefore(DateTime.now());

  bool get _isOngoing =>
      DateTime.now().isAfter(session.startTime) &&
      DateTime.now().isBefore(session.endTime);

  String get _status {
    if (_isOngoing) return 'Ongoing';
    if (_isPast) return 'Completed';
    return 'Upcoming';
  }

  Color _statusColor(ThemeData theme) {
    if (_isOngoing) return theme.colorScheme.secondary;
    if (_isPast) return theme.disabledColor;
    return theme.colorScheme.primary;
  }
}

class _SwipeAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
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
