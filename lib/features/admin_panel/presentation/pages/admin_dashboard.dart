import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/di/service_locator.dart';

import '../../domain/entities/admin_stats.dart';
import '../bloc/admin_dashboard/admin_dashboard_bloc.dart';
import '../widgets/stats_card.dart';
import '../../../../config/routes/app_routes.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminDashboardBloc>(
      create: (_) =>
          getIt<AdminDashboardBloc>()..add(const LoadDashboardEvent()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminDashboardBloc>().add(
                const RefreshDashboardEvent(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.pushNamed(AppRouteNames.profile),
          ),
        ],
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminDashboardBloc>().add(
                        const RefreshDashboardEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return _buildDashboardContent(context, state.stats);
          }

          // Fallback (should not normally reach here)
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AdminStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatsCard(
                title: 'Total Users',
                value: stats.totalUsers,
                icon: Icons.people,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                iconColor: Colors.blue[700],
              ),
              StatsCard(
                title: 'Students',
                value: stats.totalStudents,
                icon: Icons.school,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                iconColor: Colors.green[700],
              ),
              StatsCard(
                title: 'Admins',
                value: stats.totalAdmins,
                icon: Icons.admin_panel_settings,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                iconColor: Colors.orange[700],
              ),
              StatsCard(
                title: 'Tasks',
                value: stats.totalTasks,
                icon: Icons.task_alt,
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                iconColor: Colors.purple[700],
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRouteNames.userManagement),
            icon: const Icon(Icons.supervised_user_circle),
            label: const Text('Manage Users'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.teal,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Last Updated',
                  _formatDateTime(stats.lastUpdated),
                ),
                _buildInfoRow(
                  'Admin/User Ratio',
                  '${stats.totalAdmins}/${stats.totalUsers}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
