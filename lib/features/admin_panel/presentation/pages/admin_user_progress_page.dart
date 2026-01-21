import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/di/service_locator.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_analytics/admin_analytics_bloc.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/widgets/user_progress_card.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';

class AdminUserProgressPage extends StatelessWidget {
  const AdminUserProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminAnalyticsBloc>()..add(const LoadAllUserProgressEvent()),
      child: const _AdminUserProgressView(),
    );
  }
}

class _AdminUserProgressView extends StatelessWidget {
  const _AdminUserProgressView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Progress'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminAnalyticsBloc>().add(
              const RefreshUserProgressEvent(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
        builder: (context, state) {
          if (state.status == AdminAnalyticsStatus.loading) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => const ListItemSkeleton(),
            );
          }

          if (state.status == AdminAnalyticsStatus.failure) {
            return _errorView(context, state.errorMessage ?? 'Unknown error');
          }

          if (state.status == AdminAnalyticsStatus.success) {
            if (state.usersProgress.isEmpty) {
              return _emptyView();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.usersProgress.length,
              itemBuilder: (context, index) {
                final progress = state.usersProgress[index];
                return UserProgressCard(progress: progress);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AdminAnalyticsBloc>().add(
              const LoadAllUserProgressEvent(),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No progress data available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
