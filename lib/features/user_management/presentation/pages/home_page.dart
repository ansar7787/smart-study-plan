import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is! UserAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;
            final isAdmin = user.isAdmin;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================================================
                  // HEADER
                  // =========================================================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user.name}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdmin
                            ? 'Admin access enabled'
                            : 'Let’s plan your study today',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =========================================================
                  // QUICK ACTION GRID
                  // =========================================================
                  _sectionTitle('Quick Actions'),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _dashboardTile(
                        icon: Icons.menu_book,
                        label: 'Subjects',
                        color: Colors.teal,
                        onTap: () => context.go(AppRoutePaths.subjects),
                      ),
                      _dashboardTile(
                        icon: Icons.calendar_month,
                        label: 'Planner',
                        color: Colors.blue,
                        onTap: () => context.go(AppRoutePaths.calendar),
                      ),
                      _dashboardTile(
                        icon: Icons.folder_special,
                        label: 'Resources',
                        color: Colors.purple,
                        onTap: () => context.go(AppRoutePaths.resources),
                      ),
                      _dashboardTile(
                        icon: Icons.insights,
                        label: 'Analytics',
                        color: Colors.orange,
                        onTap: () => context.pushNamed(
                          AppRouteNames.analytics,
                          extra: user.id,
                        ),
                      ),
                      _dashboardTile(
                        icon: Icons.lightbulb_outline,
                        label: 'Knowledge',
                        color: Colors.deepPurple,
                        onTap: () => context.pushNamed(
                          AppRouteNames.knowledge,
                          extra: user.id,
                        ),
                      ),
                      _dashboardTile(
                        icon: Icons.notifications_active,
                        label: 'Reminders',
                        color: Colors.lightBlue,
                        onTap: () => context.pushNamed(
                          AppRouteNames.reminders,
                          extra: user.id,
                        ),
                      ),
                      if (isAdmin)
                        _dashboardTile(
                          icon: Icons.admin_panel_settings,
                          label: 'Admin',
                          color: Colors.red,
                          onTap: () =>
                              context.pushNamed(AppRouteNames.adminDashboard),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // =========================================================
                  // STUDY FLOW INFO
                  // =========================================================
                  _sectionTitle('How it works'),

                  _infoCard(
                    icon: Icons.menu_book,
                    title: 'Create Subjects',
                    subtitle: 'Organize your courses & topics',
                    color: Colors.teal,
                  ),
                  _infoCard(
                    icon: Icons.check_circle_outline,
                    title: 'Add Tasks',
                    subtitle: 'Tasks live inside each subject',
                    color: Colors.green,
                  ),
                  _infoCard(
                    icon: Icons.calendar_today,
                    title: 'Plan Sessions',
                    subtitle: 'Schedule study time in Planner',
                    color: Colors.blue,
                  ),
                  _infoCard(
                    icon: Icons.insights,
                    title: 'Track Progress',
                    subtitle: 'View analytics & streaks',
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // WIDGETS
  // =============================================================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dashboardTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
