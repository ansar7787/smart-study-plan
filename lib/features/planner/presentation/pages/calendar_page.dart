import 'dart:async' as java_timer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';

import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import 'package:smart_study_plan/features/planner/presentation/bloc/planner_state.dart';

import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart'
    as bloc_state;
// Actually, ReminderStatus is in Entity and State usually re-exports or uses it.
// Let's check: ReminderStatus is in Entity. ReminderState has ReminderStatus enum?
// Wait, I defined `enum ReminderStatus` in `reminder_state.dart` too!
// Duplicate definition. I should remove it from `reminder_state.dart` if I can use the Entity one, OR likely I made a mistake re-defining it.
// The Entity has `enum ReminderStatus { upcoming, done }`.
// The State has `enum ReminderStatus { initial, loading, success, failure }`.
// THESE ARE DIFFERENT!
// I need to rename the State one to `ReminderBlocStatus`.

import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../pages/create_session_page.dart';
import '../pages/session_timer_page.dart';
import '../widgets/session_card.dart';
import '../../../subjects/presentation/bloc/subject_bloc.dart';
import '../../../subjects/presentation/bloc/subject_event.dart';

import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

class CalendarPage extends StatefulWidget {
  final String userId;

  const CalendarPage({super.key, required this.userId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedSubjectId;
  bool _isNavigating = false;
  java_timer.Timer? _autoDeleteTimer;

  @override
  void initState() {
    super.initState();
    context.read<PlannerBloc>().add(LoadSessionsByUserEvent(widget.userId));
    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
    context.read<TaskBloc>().add(LoadTasksByUserEvent(widget.userId));

    _startAutoDeleteTimer();
  }

  void _startAutoDeleteTimer() {
    _autoDeleteTimer = java_timer.Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) {
      if (mounted) {
        _checkAndAutoDeleteSessions();
      }
    });
  }

  void _checkAndAutoDeleteSessions() {
    final state = context.read<PlannerBloc>().state;
    if (state.status != PlannerStatus.success) return;

    final now = DateTime.now();
    final expiredSessions = state.sessions.where(
      (s) => s.endTime.isBefore(now),
    );

    if (expiredSessions.isNotEmpty) {
      final bloc = context.read<PlannerBloc>();
      for (final session in expiredSessions) {
        AlarmService.instance.stopSessionAlarm(session.id);
        bloc.add(
          DeleteSessionEvent(sessionId: session.id, userId: widget.userId),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoDeleteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Study Calendar')),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          if (state.status == PlannerStatus.loading && state.sessions.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const AppShimmer(
                    width: double.infinity,
                    height: 350,
                    borderRadius: 20,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppShimmer(width: 150, height: 24),
                      const AppShimmer(width: 80, height: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListItemSkeleton(),
                  const ListItemSkeleton(),
                  const ListItemSkeleton(),
                ],
              ),
            );
          }

          if (state.status == PlannerStatus.failure && state.sessions.isEmpty) {
            return Center(
              child: Text(state.errorMessage ?? 'Error loading sessions'),
            );
          }

          final sessions = state.sessions;

          final grouped = _groupByDate(sessions);
          final selectedSessions = grouped[_normalizeDate(_selectedDay)] ?? [];

          final reminderState = context.watch<ReminderBloc>().state;
          final subjectState = context.watch<SubjectBloc>().state;

          final reminders =
              reminderState.status == bloc_state.ReminderBlocStatus.success
              ? reminderState.reminders
              : <Reminder>[];

          final reminderSessionIds = reminders
              .where(
                (r) =>
                    r.isActive &&
                    r.status ==
                        ReminderStatus
                            .upcoming && // Assuming ReminderStatus is imported
                    r.sessionId != null,
              )
              .map((r) => r.sessionId)
              .toSet();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // =====================================================
              // CALENDAR
              // =====================================================
              SliverToBoxAdapter(
                child: _CalendarCard(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  sessionsByDate: grouped,
                  onDaySelected: (day, focused) {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = focused;
                    });
                  },
                ),
              ),

              // =====================================================
              // AGENDA HEADER
              // =====================================================
              // =====================================================
              // AGENDA HEADER & FILTER
              // =====================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(_selectedDay),
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            onPressed: _openCreateSession,
                          ),
                        ],
                      ),
                      if (subjectState.subjects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedSubjectId == null,
                                onSelected: (v) =>
                                    setState(() => _selectedSubjectId = null),
                              ),
                              const SizedBox(width: 8),
                              ...subjectState.subjects.map((subject) {
                                final isSelected =
                                    _selectedSubjectId == subject.id;
                                final color = _parseColor(subject.color);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(subject.name),
                                    selected: isSelected,
                                    checkmarkColor: color,
                                    selectedColor: color.withValues(alpha: 0.2),
                                    onSelected: (v) => setState(
                                      () => _selectedSubjectId = v
                                          ? subject.id
                                          : null,
                                    ),
                                    avatar: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 6,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // =====================================================
              // EMPTY STATE
              // =====================================================
              if (selectedSessions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyAgendaState(onAdd: _openCreateSession),
                )
              // =====================================================
              // SESSION LIST
              // =====================================================
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: selectedSessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final session = selectedSessions[index];

                      // 🔍 FILTER BY SUBJECT
                      if (_selectedSubjectId != null &&
                          session.subjectId != _selectedSubjectId) {
                        return const SizedBox.shrink();
                      }

                      final hasReminder = reminderSessionIds.contains(
                        session.id,
                      );

                      // Resolve Subject Info
                      final subject = subjectState.subjects
                          .where((s) => s.id == session.subjectId)
                          .firstOrNull;

                      return SessionCard(
                        session: session,
                        hasReminder: hasReminder,
                        subjectName: subject?.name,
                        subjectColor: subject != null
                            ? _parseColor(subject.color)
                            : null,
                        onStart: () => _openSessionTimer(session),
                        onEdit: () => _openCreateSession(session),
                        onDelete: () async {
                          final bloc = context.read<PlannerBloc>();
                          await AlarmService.instance.stopSessionAlarm(
                            session.id,
                          );

                          bloc.add(
                            DeleteSessionEvent(
                              sessionId: session.id,
                              userId: widget.userId,
                            ),
                          );
                        },
                        onAddReminder: () {
                          if (hasReminder) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder is already active'),
                              ),
                            );
                          } else {
                            _createReminder(context, session);
                          }
                        },
                      );
                    },
                  ),
                ),

              // =====================================================
              // TASK LIST FOR THE DAY
              // =====================================================
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
                  final dailyTasks = taskState.tasks.where((t) {
                    return isSameDay(t.dueDate, _selectedDay);
                  }).toList();

                  if (dailyTasks.isEmpty) return const SliverToBoxAdapter();

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Tasks Due',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        SliverList.separated(
                          itemCount: dailyTasks.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = dailyTasks[index];
                            return TaskCard(
                              task: task,
                              hasReminder: false, // Simplifying for now
                              onToggle: () {
                                context.read<TaskBloc>().add(
                                  ToggleTaskEvent(task),
                                );
                              },
                              onEdit: () => context.pushNamed(
                                AppRouteNames.taskForm,
                                extra: task,
                                queryParameters: {'userId': widget.userId},
                              ),
                              onDelete: () {
                                context.read<TaskBloc>().add(
                                  DeleteTaskEvent(
                                    id: task.id,
                                    subjectId: task.subjectId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================

  Future<void> _openCreateSession([StudySession? session]) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CreateSessionPage(userId: widget.userId, session: session),
      ),
    );

    if (mounted) {
      context.read<PlannerBloc>().add(LoadSessionsByUserEvent(widget.userId));
    }

    _isNavigating = false;
  }

  Future<void> _openSessionTimer(StudySession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SessionTimerPage(session: session)),
    );
  }

  Color _parseColor(String colorDetails) {
    try {
      final hex = colorDetails.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  Map<DateTime, List<StudySession>> _groupByDate(List<StudySession> sessions) {
    final map = <DateTime, List<StudySession>>{};
    for (final session in sessions) {
      final date = _normalizeDate(session.startTime);
      map.putIfAbsent(date, () => []).add(session);
    }
    return map;
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _createReminder(
    BuildContext context,
    StudySession session,
  ) async {
    final reminderBloc = context.read<ReminderBloc>(); // ✅ capture early

    final reminderTime = session.startTime.subtract(
      const Duration(minutes: 15),
    );

    if (reminderTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot set reminder in past')),
      );
      return;
    }

    final newReminderId = const Uuid().v4();

    await AlarmService.instance.scheduleSessionAlarm(
      sessionId: session.id,
      sessionTitle: session.title,
      reminderId: newReminderId,
      reminderTime: reminderTime,
    );

    if (!mounted) return; // ✅ SAFETY CHECK

    reminderBloc.add(
      CreateReminderEvent(
        Reminder(
          id: newReminderId,
          userId: widget.userId,
          taskId: null,
          sessionId: session.id,
          subjectId: session.subjectId,
          title: session.title,
          description: session.description,
          reminderTime: reminderTime,
          isActive: true,
          reminderType: 'session',
          minutesBefore: 15,
          status: ReminderStatus.upcoming,
        ),
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for ${DateFormat('HH:mm').format(reminderTime)}',
        ),
      ),
    );
  }
}

// =============================================================
// CALENDAR CARD
// =============================================================

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<StudySession>> sessionsByDate;
  final Function(DateTime, DateTime) onDaySelected;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.sessionsByDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2100),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        eventLoader: (day) =>
            sessionsByDate[DateTime(day.year, day.month, day.day)] ?? [],

        // 🗓️ HEADER STYLE
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: colors.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: colors.primary),
          headerPadding: const EdgeInsets.symmetric(vertical: 16),
        ),

        // 🎨 CALENDAR STYLE
        calendarStyle: CalendarStyle(
          // GENERAL TEXT
          defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
          weekendTextStyle: const TextStyle(fontWeight: FontWeight.w500),
          outsideTextStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.3),
          ),

          // TODAY
          todayDecoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),

          // SELECTED
          selectedDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                HSVColor.fromColor(colors.primary).withValue(0.5).toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          // MARKERS (DOTS)
          markersMaxCount: 3,
          markerSize: 6,
          markerDecoration: BoxDecoration(
            color: colors.secondary,
            shape: BoxShape.circle,
          ),
        ),

        // 📆 DAYS OF WEEK
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: colors.error.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// EMPTY STATE
// =============================================================

class _EmptyAgendaState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAgendaState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.08),
                colors.secondary.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.auto_stories,
                  size: 32,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No sessions planned',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add study session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
