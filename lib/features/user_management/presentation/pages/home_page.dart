import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_header.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_progress_card.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_quick_access_grid.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/home/home_study_path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is! UserAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            /// 🚀 Load analytics ONCE (no lag)
            if (!_loaded) {
              _loaded = true;
              context.read<AnalyticsBloc>().add(
                LoadAnalyticsEvent(userId: user.id),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: HomeHeader()),

                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(child: HomeProgressCard()),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: HomeQuickAccessGrid(userId: user.id),
                  ),
                ),

                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
                  sliver: SliverToBoxAdapter(child: HomeStudyPath()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
