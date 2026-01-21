import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_event.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';
import 'package:smart_study_plan/features/reminder/presentation/widgets/reminder_tile.dart';

class ReminderListPage extends StatefulWidget {
  final String userId;
  const ReminderListPage({super.key, required this.userId});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    context.read<ReminderBloc>().add(GetRemindersEvent(widget.userId));
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectState = context.watch<SubjectBloc>().state;
    final isFolderMode = _selectedSubjectId == null;

    final subjectName = _selectedSubjectId == null
        ? null
        : subjectState.subjects
              .where((s) => s.id == _selectedSubjectId)
              .firstOrNull
              ?.name;

    return PopScope(
      canPop: !(_selectedSubjectId != null),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _selectedSubjectId = null);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            isFolderMode ? 'Reminders' : (subjectName ?? 'Reminders'),
          ),
          centerTitle: true,
          leading: isFolderMode
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _selectedSubjectId = null),
                ),
        ),
        body: BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            // Loading
            if (state.status == ReminderBlocStatus.loading &&
                state.reminders.isEmpty) {
              return ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: 5,
                separatorBuilder: (_, index) => SizedBox(height: 12.h),
                itemBuilder: (_, index) => const ListItemSkeleton(),
              );
            }

            // Failure
            if (state.status == ReminderBlocStatus.failure &&
                state.reminders.isEmpty) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }

            // Data
            final allReminders = state.reminders;

            if (isFolderMode) {
              // 📂 SHOW FOLDER GRID (With count)
              return _FolderGrid(
                subjects: subjectState.subjects,
                reminders: allReminders,
                onFolderTap: (id) => setState(() => _selectedSubjectId = id),
                onViewAll: () => setState(() => _selectedSubjectId = 'ALL'),
              );
            } else {
              // 📋 SHOW LIST (Filtered)
              final filtered = _selectedSubjectId == 'ALL'
                  ? allReminders
                  : _selectedSubjectId == 'UNCATEGORIZED'
                  ? allReminders.where((r) => r.subjectId == null).toList()
                  : allReminders
                        .where((r) => r.subjectId == _selectedSubjectId)
                        .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('No reminders found'),
                    ],
                  ),
                );
              }

              return _ReminderList(reminders: filtered);
            }
          },
        ),
      ),
    );
  }
}

class _ReminderList extends StatelessWidget {
  final List<Reminder> reminders;

  const _ReminderList({required this.reminders});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const Center(child: Text('No reminders set'));
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: reminders.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (_, index) {
        final reminder = reminders[index];
        return Dismissible(
          key: ValueKey(reminder.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 28.w),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) {
            context.read<ReminderBloc>().add(DeleteReminderEvent(reminder.id));
          },
          child: ReminderTile(
            reminder: reminder,
            onToggle: (v) => context.read<ReminderBloc>().add(
              ToggleReminderActiveEvent(reminder.id, v),
            ),
          ),
        );
      },
    );
  }
}

class _FolderGrid extends StatelessWidget {
  final List<dynamic> subjects;
  final List<Reminder> reminders;
  final ValueChanged<String> onFolderTap;
  final VoidCallback onViewAll;

  const _FolderGrid({
    required this.subjects,
    required this.reminders,
    required this.onFolderTap,
    required this.onViewAll,
  });

  Color _hexToColor(String hex) {
    try {
      final value = hex.replaceFirst('#', '');
      return Color(int.parse('FF$value', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uncategorizedCount = reminders
        .where((r) => r.subjectId == null)
        .length;

    return GridView(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 1.1,
      ),
      children: [
        // 'All Reminders' Card
        _FolderCard(
          title: 'All Reminders',
          subtitle: '${reminders.length} total',
          icon: Icons.all_inbox,
          onTap: onViewAll,
          color: Theme.of(context).colorScheme.primary,
        ),

        // Uncategorized
        if (uncategorizedCount > 0)
          _FolderCard(
            title: 'Uncategorized',
            subtitle: '$uncategorizedCount reminders',
            icon: Icons.help_outline_rounded,
            onTap: () => onFolderTap('UNCATEGORIZED'),
            color: Colors.grey,
          ),

        // Subject Folders
        ...subjects.map((subject) {
          final color = _hexToColor(subject.color);
          final count = reminders
              .where((r) => r.subjectId == subject.id)
              .length;

          return _FolderCard(
            title: subject.name,
            subtitle: '$count reminders',
            icon: Icons.folder_special_rounded,
            onTap: () => onFolderTap(subject.id),
            color: color,
          );
        }),
      ],
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _FolderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
