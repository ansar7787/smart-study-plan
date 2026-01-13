import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_header.dart';
import '../widgets/overview_cards.dart';
import '../widgets/study_streak_card.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/insights_list.dart';
import '../widgets/active_goals_section.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  final String userId;

  const AnalyticsDashboardPage({super.key, required this.userId});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(
      LoadAnalyticsEvent(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnalyticsLoaded) {
              final overview = state.overview;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: AnalyticsHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        OverviewCards(snapshot: overview.snapshot),
                        const SizedBox(height: 20),

                        StudyStreakCard(streak: overview.trends.studyStreak),
                        const SizedBox(height: 20),

                        WeeklyActivityChart(
                          studyHours: overview.trends.dailyStudyHours,
                          taskCompletion: overview.trends.dailyTaskCompletion,
                        ),
                        const SizedBox(height: 20),

                        InsightsList(insights: overview.insights),
                        const SizedBox(height: 20),

                        ActiveGoalsSection(goals: overview.activeGoals),
                      ]),
                    ),
                  ),
                ],
              );
            }

            if (state is AnalyticsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
