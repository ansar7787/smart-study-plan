import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/di/service_locator.dart';
import 'package:smart_study_plan/core/utils/permission_handler.dart';
import 'package:smart_study_plan/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>()..add(CheckOnboardingStatus()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  bool _minTimePassed = false;
  bool _readyToNavigate = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Run permission check and min timer concurrently
    await Future.wait([
      askNotificationPermission(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);

    if (mounted) {
      setState(() => _minTimePassed = true);
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    if (!mounted) return;

    final onboardingState = context.read<OnboardingBloc>().state;

    if (onboardingState is OnboardingRequired) {
      // 🚀 SKIP SPLASH DELAY for first time users
      context.goNamed(AppRouteNames.onboarding);
      return;
    }

    // ⏳ WAIT FOR SPLASH DELAY for returning users
    if (!_minTimePassed || !_readyToNavigate) return;

    // Only check auth if onboarding is done/not required
    if (onboardingState is OnboardingCompleted) {
      final userState = context.read<UserBloc>().state;
      if (userState.status == UserStatus.authenticated &&
          userState.user != null) {
        context.goNamed(
          userState.user!.isAdmin
              ? AppRouteNames.adminDashboard
              : AppRouteNames.home,
        );
      } else if (userState.status != UserStatus.loading) {
        context.goNamed(AppRouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: MultiBlocListener(
        listeners: [
          BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingRequired) {
                _readyToNavigate = true;
                _tryNavigate();
              } else if (state is OnboardingCompleted) {
                // Trigger auth check ONLY after onboarding is confirmed complete
                context.read<UserBloc>().add(const CheckAuthStatusEvent());
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state.status == UserStatus.authenticated ||
                  state.status == UserStatus.failure ||
                  state.status == UserStatus.unauthenticated) {
                _readyToNavigate = true;
                _tryNavigate();
              }
            },
          ),
        ],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// LOGO CONTAINER (SVG) with DEBUG RESET
              GestureDetector(
                    onDoubleTap: () async {
                      debugPrint('🔄 Resetting Onboarding...');
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', false);
                      if (context.mounted) {
                        context.goNamed(AppRouteNames.onboarding);
                      }
                    },
                    child: Container(
                      height: 100.h,
                      width: 100.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.all(22.r),
                      child: Image.asset('assets/logo/app_logo.png'),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .scale(delay: 200.ms, duration: 400.ms)
                  .shimmer(
                    delay: 1000.ms,
                    duration: 1000.ms,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),

              SizedBox(height: 32.h),

              /// APP NAME
              Text(
                    'Smart Study Planner',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 28.sp,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 400.ms,
                    curve: Curves.easeOutQuart,
                  ),

              SizedBox(height: 12.h),

              /// TAGLINE
              Text(
                    'Plan smarter. Learn better.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16.sp,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 600.ms,
                    curve: Curves.easeOutQuart,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
