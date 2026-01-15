import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_state.dart';

class HomeProgressCard extends StatelessWidget {
  const HomeProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        int total = 0;
        int done = 0;

        if (state is AnalyticsLoaded) {
          total = state.overview.snapshot.totalTasks;
          done = state.overview.snapshot.completedTasks;
        }

        final progress = total == 0 ? 0.0 : done / total;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.10),
                colors.secondary.withValues(alpha: 0.08),
                Colors.amber.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today’s progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    total == 0
                        ? colors.secondary.withValues(alpha: 0.6)
                        : colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                total == 0
                    ? 'No tasks yet — your journey starts today ✨'
                    : '$done of $total tasks completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
