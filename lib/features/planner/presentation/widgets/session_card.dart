import 'dart:async' as java_timer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/study_session.dart';

class SessionCard extends StatefulWidget {
  final StudySession session;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddReminder;
  final VoidCallback? onStart;
  final String? subjectName;
  final Color? subjectColor;
  final bool hasReminder;

  const SessionCard({
    super.key,
    required this.session,
    required this.hasReminder,
    this.onEdit,
    this.onDelete,
    this.onAddReminder,
    this.onStart,
    this.subjectName,
    this.subjectColor,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  late DateTime _now;
  java_timer.Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    // Only need a timer if it's upcoming and within 16 mins (to be safe) or ongoing
    if (_isPast) return;

    _timer = java_timer.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
        if (_isPast) {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isPast => widget.session.endTime.isBefore(_now);

  bool get _isOngoing =>
      _now.isAfter(widget.session.startTime) &&
      _now.isBefore(widget.session.endTime);

  bool get _isUpcomingButSoon =>
      widget.session.startTime.difference(_now).inMinutes <= 15 &&
      widget.session.startTime.isAfter(_now);

  String _formatCountdown() {
    final diff = widget.session.startTime.difference(_now);
    if (diff.isNegative) return "00:00";
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subjectColor = widget.subjectColor ?? colors.secondary;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (_isOngoing ? colors.primary : colors.outline).withValues(
            alpha: 0.1,
          ),
          width: _isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🎨 Subject Color Stripe
                Container(width: 6, color: subjectColor),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🏷️ Header: Subject + Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                widget.subjectName ?? 'Independent Study',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: subjectColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'HH:mm',
                              ).format(widget.session.startTime),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 📝 Title
                        Text(
                          widget.session.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isPast ? colors.outline : colors.onSurface,
                            decoration: _isPast
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),

                        if (widget.session.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.session.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // ⚡ Actions & Status
                        Row(
                          children: [
                            if (_isOngoing)
                              _StatusBadge(
                                label: 'ONGOING',
                                color: colors.primary,
                              )
                            else if (_isPast)
                              const _StatusBadge(
                                label: 'COMPLETED',
                                color: Colors.grey,
                              )
                            else if (_isUpcomingButSoon)
                              _StatusBadge(
                                label: 'STARTS IN ${_formatCountdown()}',
                                color: colors.tertiary,
                              ),

                            const Spacer(),

                            // Start Timer Button
                            if (_isOngoing)
                              IconButton.filledTonal(
                                onPressed: widget.onStart,
                                iconSize: 20,
                                icon: const Icon(Icons.play_arrow_rounded),
                                tooltip: 'Start Session',
                              ),

                            // Reminder Button
                            IconButton(
                              onPressed: widget.onAddReminder,
                              iconSize: 20,
                              icon: Icon(
                                widget.hasReminder
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_none_rounded,
                              ),
                              color: widget.hasReminder
                                  ? Colors.orange
                                  : colors.outline,
                            ),

                            // Delete Button
                            IconButton(
                              onPressed: widget.onDelete,
                              iconSize: 20,
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: colors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
