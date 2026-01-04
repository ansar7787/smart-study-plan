// Route names
import 'package:go_router/go_router.dart';

class AppRouteNames {
  static const String login = 'login';
  static const String register = 'register';
  static const String profile = 'profile';
  static const String home = 'home';
  static const String splash = 'splash';
}

// Route paths
class AppRoutePaths {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String splash = '/';
}

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.splash,
  redirect: (context, state) {
    // If user is logged in and on login/register page, redirect to home
    // If user is not logged in and on protected page, redirect to login
    return null;
  },
  routes: [
    // Splash/Home route
    GoRoute(
      path: AppRoutePaths.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // Login route
    GoRoute(
      path: AppRoutePaths.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),

    // Register route
    GoRoute(
      path: AppRoutePaths.register,
      name: AppRouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),

    // Profile route
    GoRoute(
      path: AppRoutePaths.profile,
      name: AppRouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),

    // Home/Dashboard route
    GoRoute(
      path: AppRoutePaths.home,
      name: AppRouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
