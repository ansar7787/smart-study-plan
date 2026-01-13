import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';

import '../../domain/entities/subject.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../widgets/subject_card.dart';

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

      body: BlocBuilder<SubjectBloc, BaseState<List<Subject>>>(
        builder: (context, state) {
          final viewState = state.viewState;

          if (viewState is ViewInitial || viewState is ViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewState is ViewFailure<List<Subject>>) {
            return Center(
              child: Text(
                viewState.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final subjects = (viewState as ViewSuccess<List<Subject>>).data;

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
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList.separated(
                    itemCount: subjects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$subjectCount subject${subjectCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: onAdd,
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

class _EmptySubjectState extends StatelessWidget {
  const _EmptySubjectState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
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
                radius: 36,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(Icons.menu_book, size: 34, color: colors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'No subjects yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create subjects to organize your\nstudy plan efficiently',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
