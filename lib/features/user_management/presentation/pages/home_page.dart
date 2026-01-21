import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';
import 'package:smart_study_plan/core/widgets/skeletons/grid_item_skeleton.dart';

import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_event.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_state.dart';

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
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userState = context.read<UserBloc>().state;
    if (userState.status == UserStatus.authenticated &&
        userState.user != null) {
      context.read<AnalyticsBloc>().add(
        LoadAnalyticsEvent(userId: userState.user!.id),
      );
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userState.user!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.authenticated) {
            _loadData(); // detailed load if auth changes
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            // Loading
            if (state.status == UserStatus.loading && state.user == null) {
              return _buildLoadingState(context);
            }

            final user = state.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.paddingOf(context).top),
                ),
                SliverToBoxAdapter(
                  child: const HomeHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                ),

                // 📊 PROGRESS CARD
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: const HomeProgressCard()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          delay: 200.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                ),

                // 📂 FOLDERS (SUBJECTS) CAROUSEL
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 0, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            'My Folders',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.sp,
                                ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                              height: 130.h,
                              child: BlocBuilder<SubjectBloc, SubjectState>(
                                builder: (context, state) {
                                  if (state.status == SubjectStatus.loading) {
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: List.generate(
                                        3,
                                        (i) => Padding(
                                          padding: EdgeInsets.only(right: 12.w),
                                          child: AppShimmer(
                                            width: 130.w,
                                            height: 130.h,
                                            borderRadius: 20.r,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  if (state.subjects.isEmpty) {
                                    return _buildAddSubjectCard(context);
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.subjects.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == state.subjects.length) {
                                        return Padding(
                                          padding: EdgeInsets.only(right: 16.w),
                                          child: _buildAddSubjectCard(context),
                                        );
                                      }
                                      final subject = state.subjects[index];
                                      return _buildSubjectCard(
                                        context,
                                        subject,
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideX(begin: 0.1, end: 0),
                      ],
                    ),
                  ),
                ),

                // 🚀 ACTIONS GRID
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: HomeQuickAccessGrid(userId: user.id)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                ),

                // 🛤️ STUDY PATH
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 32.h),
                  sliver: SliverToBoxAdapter(
                    child: const HomeStudyPath()
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 600.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, dynamic subject) {
    Color color;
    try {
      color = Color(
        int.parse(subject.color.replaceFirst('#', 'FF'), radix: 16),
      );
    } catch (_) {
      color = Colors.blue;
    }

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: () {
          // Navigate to Subject Details or Tasks
          context.pushNamed(
            AppRouteNames.tasks,
            pathParameters: {'subjectId': subject.id},
            extra: subject.name,
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 140.w,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.folder_rounded, color: color, size: 32.sp),
              Text(
                subject.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSubjectCard(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(AppRouteNames.subjects),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 100.w, // Smaller for "Add"
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 32.sp),
            SizedBox(height: 4.h),
            Text(
              'Add',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0.r),
            child: Row(
              children: [
                const AppShimmer.round(size: 48),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(width: 100.w, height: 12.h),
                    SizedBox(height: 8.h),
                    AppShimmer(width: 150.w, height: 20.h),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppShimmer(
              width: double.infinity,
              height: 180.h,
              borderRadius: 24.r,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16.r),
          sliver: SliverGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 0.95,
            children: List.generate(6, (index) => const GridItemSkeleton()),
          ),
        ),
      ],
    );
  }
}
