import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';

import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
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

    context.read<TaskBloc>().add(
      LoadTasksBySubjectEvent(
        subjectId: widget.subjectId,
        userId: widget.userId,
      ),
    );

    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(widget.subjectName)),

      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading && state.tasks.isEmpty) {
            return Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: const [
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                  ],
                ),
              ),
            );
          }

          if (state.status == TaskStatus.failure && state.tasks.isEmpty) {
            return Center(
              child: Text(state.errorMessage ?? 'Error loading tasks'),
            );
          }

          if (state.tasks.where((t) => !t.isCompleted).isEmpty &&
              state.tasks.isNotEmpty) {
            // If all tasks are completed, show empty state or a special "All done" state?
            // For now, let's just use the empty state but maybe tweak text if we wanted.
            // Using standard empty state for simplicity as per "automatic delete" req.
            return _EmptyTaskState(onAdd: _openCreateTask);
          }

          if (state.tasks.isEmpty) {
            return _EmptyTaskState(onAdd: _openCreateTask);
          }

          return BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, reminderState) {
              final reminders =
                  reminderState.status == ReminderBlocStatus.success
                  ? reminderState.reminders
                  : <Reminder>[];

              final activeTasks = state.tasks
                  .where((t) => !t.isCompleted)
                  .toList();
              // Sort by due date (optional but good)
              activeTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

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
                      taskCount: activeTasks.length, // Show active count
                      onAddTask: _openCreateTask,
                    ),
                  ),

                  /// 📋 TASK LIST / EMPTY STATE
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    sliver: SliverList.separated(
                      itemCount: activeTasks.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final task = activeTasks[index];
                        final hasReminder = reminderTaskIds.contains(task.id);

                        return TaskCard(
                          task: task,
                          hasReminder: hasReminder,
                          onToggle: () {
                            final taskBloc = context.read<TaskBloc>();
                            taskBloc.add(ToggleTaskEvent(task));

                            // Show Undo Snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Task completed'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // FORCE set to incomplete to "undo" the completion
                                    taskBloc.add(
                                      UpdateTaskEvent(
                                        task.copyWith(isCompleted: false),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );

                            // stop alarm if completed
                            if (!task.isCompleted) {
                              AlarmService.instance.stopTaskAlarm(task.id);
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

    final newReminderId = const Uuid().v4();

    await AlarmService.instance.scheduleTaskAlarm(
      taskId: task.id,
      taskTitle: task.title,
      reminderId: newReminderId,
      reminderTime: reminderTime,
    );

    if (!mounted) return;

    context.read<ReminderBloc>().add(
      CreateReminderEvent(
        Reminder(
          id: newReminderId,
          userId: widget.userId,
          taskId: task.id,
          sessionId: null,
          subjectId: widget.subjectId,
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔙 BACK BUTTON
              IconButton.filledTonal(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),

              // ➕ ADD BUTTON
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 📁 FOLDER INFO
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.folder_open,
                  size: 32.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$taskCount active tasks',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌈 ICON CONTAINER
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.18),
                    colors.secondary.withValues(alpha: 0.12),
                  ],
                ),
              ),
              child: Icon(Icons.task_alt, size: 64.sp, color: colors.primary),
            ),

            SizedBox(height: 24.h),

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
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
