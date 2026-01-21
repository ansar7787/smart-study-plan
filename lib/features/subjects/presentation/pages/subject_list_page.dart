import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../widgets/subject_card.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';

class SubjectListPage extends StatefulWidget {
  final String userId;

  const SubjectListPage({super.key, required this.userId});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Subjects')),

      body: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          if (state.status == SubjectStatus.loading && state.subjects.isEmpty) {
            return Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: const [
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                  ],
                ),
              ),
            );
          }

          if (state.status == SubjectStatus.failure && state.subjects.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final subjects = state.subjects;

          return CustomScrollView(
            slivers: [
              /// 🧠 HEADER
              SliverToBoxAdapter(
                child: _SubjectHeader(
                  subjectCount: subjects.length,
                  onAdd: _openCreateSubject,
                ),
              ),

              /// 📭 EMPTY
              if (subjects.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptySubjectState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  sliver: SliverList.separated(
                    itemCount: subjects.length,
                    separatorBuilder: (_, _) => SizedBox(height: 6.h),
                    itemBuilder: (context, index) {
                      final subject = subjects[index];

                      return SubjectCard(
                        subject: subject,
                        onViewTasks: () {
                          context.pushNamed(
                            AppRouteNames.tasks,
                            pathParameters: {'subjectId': subject.id},
                            extra: subject.name,
                          );
                        },
                        onEdit: () {
                          context.pushNamed(
                            AppRouteNames.subjectForm,
                            extra: subject,
                          );
                        },
                        onDelete: () => _showDeleteDialog(context, subject.id),
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

  void _openCreateSubject() {
    context.pushNamed(AppRouteNames.subjectForm);
  }

  void _showDeleteDialog(BuildContext context, String subjectId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete subject?'),
        content: const Text('This will remove all related tasks & sessions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SubjectBloc>().add(DeleteSubjectEvent(subjectId));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final int subjectCount;
  final VoidCallback onAdd;

  const _SubjectHeader({required this.subjectCount, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '$subjectCount subject${subjectCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.65),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18.sp, color: colors.primary),
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

class _EmptySubjectState extends StatelessWidget {
  const _EmptySubjectState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.r),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.08),
                colors.secondary.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36.r,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.menu_book,
                  size: 34.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No subjects yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Create subjects to organize your\nstudy plan efficiently',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
