import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/core/widgets/app_shimmer.dart';
import 'package:smart_study_plan/core/widgets/skeletons/dashboard_card_skeleton.dart';
import '../../../subjects/presentation/bloc/subject_bloc.dart';
import '../../../subjects/presentation/bloc/subject_event.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_header.dart';
import '../widgets/overview_cards.dart';
import '../widgets/study_streak_card.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/insights_list.dart';
import '../widgets/active_goals_section.dart';
import '../widgets/performance_gauge.dart';
import '../widgets/subject_distribution_chart.dart';
import '../widgets/consistency_heatmap.dart';
import '../widgets/focus_analysis_card.dart';
import '../../../user_management/presentation/bloc/user_bloc.dart';
import '../widgets/gamification_card.dart';
import '../../domain/entities/analytics_overview.dart';
import '../../domain/entities/progress_snapshot.dart';

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
    // Ensure subjects are loaded for mapping names/colors
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Analytics'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Focus'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state.status == AnalyticsStatus.loading &&
                  state.overview == null) {
                return _buildLoadingShim();
              }

              if (state.status == AnalyticsStatus.failure &&
                  state.overview == null) {
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Error loading analytics',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state.overview != null) {
                final overview = state.overview!;
                final snapshot = overview.snapshot;

                // Access SubjectBloc state to map IDs to Names/Colors
                final subjectState = context.watch<SubjectBloc>().state;
                final subjectMap = {
                  for (var s in subjectState.subjects) s.id: s,
                };

                // Prepare Chart Data
                final (timeData, timeColors) = _prepareChartData(
                  overview.subjectDistribution,
                  subjectMap,
                );
                final (taskData, taskColors) = _prepareChartData(
                  // Cast Map<String, int> to Map<String, double> for helper
                  overview.taskDistribution.map(
                    (k, v) => MapEntry(k, v.toDouble()),
                  ),
                  subjectMap,
                );

                return TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // TAB 1: OVERVIEW
                    _buildOverviewTab(overview, snapshot),

                    // TAB 2: FOCUS
                    _buildFocusTab(overview),

                    // TAB 3: TRENDS
                    _buildTrendsTab(
                      overview,
                      timeData,
                      timeColors,
                      taskData,
                      taskColors,
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    AnalyticsOverview overview,
    ProgressSnapshot snapshot,
  ) {
    // Get real user name
    final userState = context.read<UserBloc>().state;
    final userName = userState.user?.name ?? 'Scholar';

    return SingleChildScrollView(
      // Add scroll to tab content
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnalyticsHeader(),
          const SizedBox(height: 16),
          // GAMIFICATION (Real Data)
          GamificationCard(
            totalPoints: overview.totalPoints,
            userName: userName,
          ),
          const SizedBox(height: 16),
          PerformanceGauge(
            score: (snapshot.completionPercentage).clamp(0, 100).toDouble(),
            label: 'Task Completion',
          ),
          const SizedBox(height: 24),
          OverviewCards(snapshot: snapshot),
          const SizedBox(height: 24),
          InsightsList(insights: overview.insights),
          const SizedBox(height: 24),
          ActiveGoalsSection(goals: overview.activeGoals),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFocusTab(AnalyticsOverview overview) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FocusAnalysisCard(
            bestHour: overview.bestFocusHour,
            averageDuration: overview.averageSessionDuration,
          ),
          const SizedBox(height: 24),
          ConsistencyHeatmap(datasets: overview.studyHeatmap),
          const SizedBox(height: 24),
          StudyStreakCard(streak: overview.trends.studyStreak),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(
    AnalyticsOverview overview,
    Map<String, double> timeData,
    Map<String, Color> timeColors,
    Map<String, double> taskData,
    Map<String, Color> taskColors,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          WeeklyActivityChart(
            studyHours: overview.trends.dailyStudyHours,
            taskCompletion: overview.trends.dailyTaskCompletion,
          ),
          const SizedBox(height: 24),
          if (timeData.isNotEmpty)
            SubjectDistributionChart(
              title: 'Time Distribution (Hours)',
              data: timeData,
              colors: timeColors,
            )
          else
            const Center(child: Text("No time data recorded yet.")),
          const SizedBox(height: 24),
          if (taskData.isNotEmpty)
            SubjectDistributionChart(
              title: 'Task Distribution (Count)',
              data: taskData,
              colors: taskColors,
            )
          else
            const Center(child: Text("No task data recorded yet.")),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  (Map<String, double>, Map<String, Color>) _prepareChartData(
    Map<String, double> rawData,
    Map<String, dynamic> subjectMap,
  ) {
    final Map<String, double> data = {};
    final Map<String, Color> colors = {};

    rawData.forEach((subjectId, value) {
      if (subjectId == 'Unknown') {
        data['Others'] = (data['Others'] ?? 0) + value;
        colors['Others'] = Colors.grey;
      } else {
        final subject = subjectMap[subjectId];
        final name = subject?.name ?? 'Deleted Subject';
        Color color = Colors.grey;
        if (subject?.color != null) {
          try {
            final hex = subject!.color.replaceAll('#', '');
            color = Color(int.parse('FF$hex', radix: 16));
          } catch (_) {}
        }
        data[name] = (data[name] ?? 0) + value;
        colors[name] = color;
      }
    });

    return (data, colors);
  }

  Widget _buildLoadingShim() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const AppShimmer(
            width: double.infinity,
            height: 100,
            borderRadius: 24,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: DashboardCardSkeleton()),
              SizedBox(width: 16),
              Expanded(child: DashboardCardSkeleton()),
            ],
          ),
          const SizedBox(height: 16),
          const AppShimmer(
            width: double.infinity,
            height: 250,
            borderRadius: 24,
          ),
        ],
      ),
    );
  }
}
