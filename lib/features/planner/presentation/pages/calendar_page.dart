import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';

import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart';

import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../pages/create_session_page.dart';
import '../widgets/session_card.dart';

class CalendarPage extends StatefulWidget {
  final String userId;

  const CalendarPage({super.key, required this.userId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    context.read<PlannerBloc>().add(LoadSessionsByUserEvent(widget.userId));
    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Study Calendar')),
      body: BlocBuilder<PlannerBloc, BaseState<List<StudySession>>>(
        builder: (context, state) {
          final viewState = state.viewState;

          if (viewState is ViewInitial || viewState is ViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewState is ViewFailure<List<StudySession>>) {
            return Center(child: Text(viewState.message));
          }

          final sessions = (viewState as ViewSuccess<List<StudySession>>).data;

          final grouped = _groupByDate(sessions);
          final selectedSessions = grouped[_normalizeDate(_selectedDay)] ?? [];

          final reminderState = context.watch<ReminderBloc>().state;
          final reminders = reminderState is RemindersLoaded
              ? reminderState.reminders
              : <Reminder>[];

          final reminderSessionIds = reminders
              .where(
                (r) =>
                    r.isActive &&
                    r.status == ReminderStatus.upcoming &&
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
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
                      final hasReminder = reminderSessionIds.contains(
                        session.id,
                      );

                      return SessionCard(
                        session: session,
                        hasReminder: hasReminder,
                        onEdit: _openCreateSession,
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
                        onAddReminder: hasReminder
                            ? null
                            : () => _createReminder(context, session),
                      );
                    },
                  ),
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

  Future<void> _openCreateSession() async {
    if (_isNavigating) return;
    _isNavigating = true;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateSessionPage(userId: widget.userId),
      ),
    );

    if (mounted) {
      context.read<PlannerBloc>().add(LoadSessionsByUserEvent(widget.userId));
    }

    _isNavigating = false;
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

    await AlarmService.instance.scheduleSessionAlarm(
      sessionId: session.id,
      sessionTitle: session.title,
      reminderTime: reminderTime,
    );

    if (!mounted) return; // ✅ SAFETY CHECK

    reminderBloc.add(
      CreateReminderEvent(
        Reminder(
          id: const Uuid().v4(),
          userId: widget.userId,
          taskId: null,
          sessionId: session.id,
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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.05),
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
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: theme.textTheme.titleLarge!,
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
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
