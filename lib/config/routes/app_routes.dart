import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:smart_study_plan/features/admin_panel/presentation/admin_shell/admin_shell.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/pages/admin_dashboard.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/pages/user_management_page.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/pages/admin_user_progress_page.dart';

import 'package:smart_study_plan/features/knowledge/presentation/pages/knowledge_hub_page.dart';
import 'package:smart_study_plan/features/reminder/presentation/pages/reminder_list_page.dart';
import 'package:smart_study_plan/features/reminder/presentation/pages/alarm_ring_page.dart';
import 'package:alarm/alarm.dart';

import 'package:smart_study_plan/features/subjects/domain/entities/subject.dart';
import 'package:smart_study_plan/features/subjects/presentation/pages/subject_form_page.dart';
import 'package:smart_study_plan/features/subjects/presentation/pages/subject_list_page.dart';

import 'package:smart_study_plan/features/tasks/domain/entities/task.dart';
import 'package:smart_study_plan/features/tasks/presentation/pages/task_form_page.dart';
import 'package:smart_study_plan/features/tasks/presentation/pages/task_list_page.dart';

import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/forgot_password_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/home_page.dart';
import 'package:smart_study_plan/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/login_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/profile_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/register_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/reset_email_sent_page.dart';
import 'package:smart_study_plan/features/user_management/presentation/pages/splash_page.dart';

import 'package:smart_study_plan/features/planner/presentation/pages/calendar_page.dart';
import 'package:smart_study_plan/features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'package:smart_study_plan/features/resources/presentation/pages/resource_library_page.dart';

// =====================================================
// ROUTE NAMES
// =====================================================

class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot_password';
  static const resetEmailSent = 'reset_email_sent';
  static const home = 'home';
  static const profile = 'profile';
  static const onboarding = 'onboarding';

  // ADMIN
  static const adminDashboard = 'admin_dashboard';
  static const userManagement = 'user_management';
  static const adminUserProgress = 'admin_user_progress';

  // USER
  static const subjects = 'subjects';
  static const subjectForm = 'subject_form';
  static const tasks = 'tasks';
  static const taskForm = 'task_form';
  static const calendar = 'calendar';
  static const analytics = 'analytics';
  static const resources = 'resources';
  static const reminders = 'reminders';
  static const knowledge = 'knowledge';
  static const alarmRing = 'alarm_ring';
}

// =====================================================
// ROUTE PATHS
// =====================================================

class AppRoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetEmailSent = '/reset-email-sent';

  static const home = '/home';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const subjects = '/subjects';
  static const calendar = '/calendar';
  static const resources = '/resources';
  static const analytics = '/analytics';
  static const knowledge = '/knowledge';
  static const reminders = '/reminders';

  static const subjectForm = '/subject-form';
  static const tasks = '/tasks/:subjectId';
  static const taskForm = '/task-form';

  // ADMIN
  static const adminDashboard = '/admin/dashboard';
  static const userManagement = '/admin/users';
  static const adminUserProgress = '/admin/user-progress';
  static const alarmRing = '/alarm-ring';
}

// =====================================================
// HELPERS
// =====================================================

String _currentUserId(BuildContext context) {
  final state = context.read<UserBloc>().state;
  return state.status == UserStatus.authenticated && state.user != null
      ? state.user!.id
      : '';
}

// =====================================================
// GO ROUTER
// =====================================================

// =====================================================
// GO ROUTER
// =====================================================

GoRouter createAppRouter(UserBloc userBloc) {
  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(userBloc.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final blocState = userBloc.state;

      // ✅ Always allow splash & reset flow
      if (location == AppRoutePaths.splash ||
          location == AppRoutePaths.onboarding ||
          location == AppRoutePaths.forgotPassword ||
          location == AppRoutePaths.resetEmailSent) {
        return null;
      }

      final loggedIn =
          blocState.status == UserStatus.authenticated &&
          blocState.user != null;
      final admin = loggedIn && blocState.user!.isAdmin;

      // 🔒 Admin protection
      if (location.startsWith('/admin')) {
        if (!loggedIn) return AppRoutePaths.login;
        if (!admin) return AppRoutePaths.home;
      }

      // 🔐 Auth guard
      if (!loggedIn &&
          location != AppRoutePaths.login &&
          location != AppRoutePaths.register) {
        return AppRoutePaths.login;
      }

      // 🚫 Block auth pages after login
      if (loggedIn &&
          (location == AppRoutePaths.login ||
              location == AppRoutePaths.register)) {
        return AppRoutePaths.home;
      }

      return null;
    },

    routes: [
      /// AUTH
      GoRoute(
        path: AppRoutePaths.splash,
        name: AppRouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutePaths.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutePaths.resetEmailSent,
        name: AppRouteNames.resetEmailSent,
        builder: (_, _) => const ResetEmailSentPage(),
      ),

      /// ONBOARDING
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: AppRouteNames.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),

      /// USER (NO SHELL, FULL SCREEN)
      GoRoute(
        path: AppRoutePaths.home,
        name: AppRouteNames.home,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        name: AppRouteNames.profile,
        builder: (_, _) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutePaths.subjects,
        name: AppRouteNames.subjects,
        builder: (context, _) =>
            SubjectListPage(userId: _currentUserId(context)),
      ),
      GoRoute(
        path: AppRoutePaths.calendar,
        name: AppRouteNames.calendar,
        builder: (context, _) => CalendarPage(userId: _currentUserId(context)),
      ),
      GoRoute(
        path: AppRoutePaths.resources,
        name: AppRouteNames.resources,
        builder: (context, _) =>
            ResourceLibraryPage(userId: _currentUserId(context)),
      ),
      GoRoute(
        path: AppRoutePaths.analytics,
        name: AppRouteNames.analytics,
        builder: (context, _) =>
            AnalyticsDashboardPage(userId: _currentUserId(context)),
      ),
      GoRoute(
        path: AppRoutePaths.knowledge,
        name: AppRouteNames.knowledge,
        builder: (context, _) =>
            KnowledgeHubPage(userId: _currentUserId(context)),
      ),
      GoRoute(
        path: AppRoutePaths.reminders,
        name: AppRouteNames.reminders,
        builder: (context, _) =>
            ReminderListPage(userId: _currentUserId(context)),
      ),

      /// ADMIN (KEEP SHELL)
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutePaths.adminDashboard,
            name: AppRouteNames.adminDashboard,
            builder: (_, _) => const AdminDashboard(),
          ),
          GoRoute(
            path: AppRoutePaths.userManagement,
            name: AppRouteNames.userManagement,
            builder: (_, _) => const UserManagementPage(),
          ),
          GoRoute(
            path: AppRoutePaths.adminUserProgress,
            name: AppRouteNames.adminUserProgress,
            builder: (_, _) => const AdminUserProgressPage(),
          ),
        ],
      ),

      /// OTHER
      GoRoute(
        path: AppRoutePaths.subjectForm,
        name: AppRouteNames.subjectForm,
        builder: (context, state) => SubjectFormPage(
          subject: state.extra as Subject?,
          userId: _currentUserId(context),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.tasks,
        name: AppRouteNames.tasks,
        builder: (context, state) => TaskListPage(
          userId: _currentUserId(context),
          subjectId: state.pathParameters['subjectId']!,
          subjectName: state.extra as String? ?? 'Tasks',
        ),
      ),
      GoRoute(
        path: AppRoutePaths.taskForm,
        name: AppRouteNames.taskForm,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Task) {
            return TaskFormPage(task: extra, userId: _currentUserId(context));
          } else if (extra is Map<String, dynamic>) {
            return TaskFormPage(
              subjectId: extra['subjectId'] as String?,
              userId: _currentUserId(context),
            );
          }
          return TaskFormPage(userId: _currentUserId(context));
        },
      ),
      GoRoute(
        path: AppRoutePaths.alarmRing,
        name: AppRouteNames.alarmRing,
        builder: (_, state) {
          final settings = state.extra as AlarmSettings;
          return AlarmRingPage(alarmSettings: settings);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
