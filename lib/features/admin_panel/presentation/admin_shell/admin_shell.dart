import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith(AppRoutePaths.userManagement)) return 1;
    if (location.startsWith(AppRoutePaths.adminUserProgress)) return 2;
    return 0; // dashboard
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(AppRouteNames.adminDashboard);
        break;
      case 1:
        context.goNamed(AppRouteNames.userManagement);
        break;
      case 2:
        context.goNamed(AppRouteNames.adminUserProgress);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTap(context, i),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
