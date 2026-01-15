import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  bool _authChecked = false;
  bool _minTimePassed = false;

  @override
  void initState() {
    super.initState();

    /// Fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    /// Minimum splash duration (800ms)
    Timer(const Duration(milliseconds: 800), () {
      _minTimePassed = true;
      _tryNavigate();
    });

    /// Trigger auth check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const CheckAuthStatusEvent());
    });
  }

  void _tryNavigate() {
    if (!mounted) return;
    if (_authChecked && _minTimePassed) {
      final state = context.read<UserBloc>().state;

      if (state is UserAuthenticated) {
        context.goNamed(
          state.user.isAdmin
              ? AppRouteNames.adminDashboard
              : AppRouteNames.home,
        );
      } else {
        context.goNamed(AppRouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (!mounted) return;

          if (state is UserAuthenticated ||
              state is UserNotAuthenticated ||
              state is UserError) {
            _authChecked = true;
            _tryNavigate();
          }
        },
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// LOGO CONTAINER (SVG)
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: SvgPicture.asset('assets/logo/app_logo.svg'),
                ),

                const SizedBox(height: 28),

                /// APP NAME
                Text(
                  'Smart Study Planner',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                /// TAGLINE
                Text(
                  'Plan smarter. Learn better.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
