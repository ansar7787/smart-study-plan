import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';

import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/task_card.dart';

class TaskListPage extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String userId;

  const TaskListPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.userId,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();

    context.read<TaskBloc>().add(LoadTasksBySubjectEvent(widget.subjectId));

    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(widget.subjectName)),

      body: BlocBuilder<TaskBloc, BaseState<List<Task>>>(
        builder: (context, taskState) {
          final viewState = taskState.viewState;

          if (viewState is ViewInitial || viewState is ViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewState is ViewFailure<List<Task>>) {
            return Center(child: Text(viewState.message));
          }

          final tasks = (viewState as ViewSuccess<List<Task>>).data;

          return BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, reminderState) {
              final reminders = reminderState is RemindersLoaded
                  ? reminderState.reminders
                  : <Reminder>[];

              final reminderTaskIds = reminders
                  .where(
                    (r) =>
                        r.isActive &&
                        r.status == ReminderStatus.upcoming &&
                        r.taskId != null,
                  )
                  .map((r) => r.taskId)
                  .toSet();

              return CustomScrollView(
                slivers: [
                  /// 🧠 HEADER (ALWAYS VISIBLE)
                  SliverToBoxAdapter(
                    child: _TaskHeader(
                      subjectName: widget.subjectName,
                      taskCount: tasks.length,
                      onAddTask: _openCreateTask,
                    ),
                  ),

                  /// 📋 TASK LIST / EMPTY STATE
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 24),
                    sliver: tasks.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyTaskState(onAdd: _openCreateTask),
                          )
                        : SliverList.separated(
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 4),
                            itemBuilder: (_, index) {
                              final task = tasks[index];
                              final hasReminder = reminderTaskIds.contains(
                                task.id,
                              );

                              return TaskCard(
                                task: task,
                                hasReminder: hasReminder,

                                // ✅ REQUIRED FIX
                                onToggle: () {
                                  context.read<TaskBloc>().add(
                                    ToggleTaskEvent(task),
                                  );

                                  // stop alarm if completed
                                  if (!task.isCompleted) {
                                    AlarmService.instance.stopTaskAlarm(
                                      task.id,
                                    );
                                    context.read<ReminderBloc>().add(
                                      MarkReminderDoneByTaskEvent(task.id),
                                    );
                                  }
                                },

                                onEdit: () => context.pushNamed(
                                  AppRouteNames.taskForm,
                                  extra: task,
                                ),

                                onDelete: () => _deleteTask(context, task),

                                onAddReminder: hasReminder
                                    ? null
                                    : () => _createTaskReminder(task),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void _openCreateTask() {
    context.pushNamed(
      AppRouteNames.taskForm,
      extra: {'subjectId': widget.subjectId},
    );
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final taskBloc = context.read<TaskBloc>();

    final reminderBloc = context.read<ReminderBloc>();
    await AlarmService.instance.stopTaskAlarm(task.id);
    if (!mounted) return;

    taskBloc.add(DeleteTaskEvent(id: task.id, subjectId: widget.subjectId));

    reminderBloc.add(MarkReminderDoneByTaskEvent(task.id));
  }

  Future<void> _createTaskReminder(Task task) async {
    final reminderTime = task.dueDate.subtract(const Duration(minutes: 30));

    if (reminderTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot set reminder in past')),
      );
      return;
    }

    await AlarmService.instance.scheduleTaskAlarm(
      taskId: task.id,
      taskTitle: task.title,
      reminderTime: reminderTime,
    );

    if (!mounted) return;

    context.read<ReminderBloc>().add(
      CreateReminderEvent(
        Reminder(
          id: const Uuid().v4(),
          userId: widget.userId,
          taskId: task.id,
          sessionId: null,
          title: task.title,
          description: task.description,
          reminderTime: reminderTime,
          isActive: true,
          reminderType: 'task',
          minutesBefore: 30,
          status: ReminderStatus.upcoming,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for ${DateFormat('MMM dd, hh:mm a').format(reminderTime)}',
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   HEADER                                   */
/* -------------------------------------------------------------------------- */

class _TaskHeader extends StatelessWidget {
  final String subjectName;
  final int taskCount;
  final VoidCallback onAddTask;

  const _TaskHeader({
    required this.subjectName,
    required this.taskCount,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.10),
              colors.secondary.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            /// 📘 TITLE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$taskCount task${taskCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            /// ➕ SOFT ADD ACTION
            InkWell(
              onTap: onAddTask,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Add',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               EMPTY STATE                                  */
/* -------------------------------------------------------------------------- */

class _EmptyTaskState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTaskState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌈 ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.18),
                    colors.secondary.withValues(alpha: 0.12),
                  ],
                ),
              ),
              child: Icon(Icons.task_alt, size: 64, color: colors.primary),
            ),

            const SizedBox(height: 24),

            Text(
              'No tasks yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Break your study goals into smaller tasks',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create your first task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
