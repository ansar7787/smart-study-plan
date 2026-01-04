import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/pages/admin_dashboard.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/pages/user_management.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/home_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/login_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/profile_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/register_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/splash_page.dart';

// Route names
class AppRouteNames {
  static const String login = 'login';
  static const String register = 'register';
  static const String profile = 'profile';
  static const String home = 'home';
  static const String splash = 'splash';
  // Admin routes
  static const String adminDashboard = 'admin_dashboard';
  static const String userManagement = 'user_management';
}

// Route paths
class AppRoutePaths {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String splash = '/';
  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
}

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.splash,
  redirect: (context, state) {
    return null;
  },
  routes: [
    // Existing routes...
    GoRoute(
      path: AppRoutePaths.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutePaths.register,
      name: AppRouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutePaths.profile,
      name: AppRouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutePaths.home,
      name: AppRouteNames.home,
      builder: (context, state) => const HomePage(),
    ),

    // Admin routes - ADD THESE
    GoRoute(
      path: AppRoutePaths.adminDashboard,
      name: AppRouteNames.adminDashboard,
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: AppRoutePaths.userManagement,
      name: AppRouteNames.userManagement,
      builder: (context, state) => const UserManagementPage(),
    ),
  ],
);
