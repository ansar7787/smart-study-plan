import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/di/service_locator.dart';

import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/widgets/stats_card.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/core/widgets/skeletons/dashboard_card_skeleton.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminDashboardBloc>(
      create: (_) =>
          getIt<AdminDashboardBloc>()..add(const LoadAdminDashboardEvent()),
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
                const RefreshAdminDashboardEvent(),
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
          if (state.status == AdminDashboardStatus.loading) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      DashboardCardSkeleton(),
                      DashboardCardSkeleton(),
                      DashboardCardSkeleton(),
                      DashboardCardSkeleton(),
                    ],
                  ),
                ],
              ),
            );
          }

          if (state.status == AdminDashboardStatus.failure) {
            return _ErrorView(message: state.errorMessage ?? 'Unknown error');
          }

          if (state.status == AdminDashboardStatus.success &&
              state.stats != null) {
            return _DashboardContent(stats: state.stats!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// =====================================================
// DASHBOARD CONTENT
// =====================================================

class _DashboardContent extends StatelessWidget {
  final AdminStats stats;

  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
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

          // ------------------ STATS GRID ------------------
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
                iconColor: Colors.blue,
              ),
              StatsCard(
                title: 'Students',
                value: stats.totalStudents,
                icon: Icons.school,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                iconColor: Colors.green,
              ),
              StatsCard(
                title: 'Admins',
                value: stats.totalAdmins,
                icon: Icons.admin_panel_settings,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                iconColor: Colors.orange,
              ),
              StatsCard(
                title: 'Tasks',
                value: stats.totalTasks,
                icon: Icons.task_alt,
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                iconColor: Colors.purple,
              ),
            ],
          ),

          // ------------------ QUICK ACTIONS ------------------
          const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _AdminActionCard(
                  title: 'Manage Users',
                  subtitle: 'View, delete & roles',
                  icon: Icons.people_alt,
                  color: Colors.teal,
                  onTap: () => context.pushNamed(AppRouteNames.userManagement),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AdminActionCard(
                  title: 'User Progress',
                  subtitle: 'Analytics & performance',
                  icon: Icons.insights,
                  color: Colors.indigo,
                  onTap: () =>
                      context.pushNamed(AppRouteNames.adminUserProgress),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ------------------ QUICK INFO ------------------
          _QuickInfo(stats: stats),
        ],
      ),
    );
  }
}

// =====================================================
// QUICK INFO
// =====================================================

class _QuickInfo extends StatelessWidget {
  final AdminStats stats;

  const _QuickInfo({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _infoRow('Last Updated', _format(stats.lastUpdated)),
          _infoRow(
            'Admin/User Ratio',
            '${stats.totalAdmins}/${stats.totalUsers}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _format(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// =====================================================
// ADMIN ACTION CARD
// =====================================================

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// ERROR VIEW
// =====================================================

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AdminDashboardBloc>().add(
                const LoadAdminDashboardEvent(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
