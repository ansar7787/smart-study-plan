import 'package:equatable/equatable.dart';
import 'progress_snapshot.dart';
import 'progress_trends.dart';
import 'analytics_insight.dart';
import 'study_goal.dart';

class AnalyticsOverview extends Equatable {
  final ProgressSnapshot snapshot;
  final ProgressSnapshot todaySnapshot; // ✅ NEW
  final ProgressTrends trends;
  final List<StudyGoal> activeGoals;
  final List<AnalyticsInsight> insights;

  final Map<String, double> subjectDistribution;
  final Map<String, int> taskDistribution;

  // New Metrics for Revamp
  final Map<DateTime, int> studyHeatmap; // Day -> Minutes
  final double averageSessionDuration; // Minutes
  final int bestFocusHour; // 0-23
  final int totalPoints; // ✅ NEW: Gamification

  const AnalyticsOverview({
    required this.snapshot,
    required this.todaySnapshot,
    required this.trends,
    required this.activeGoals,
    required this.insights,
    required this.subjectDistribution,
    required this.taskDistribution,
    required this.studyHeatmap,
    required this.averageSessionDuration,
    required this.bestFocusHour,
    required this.totalPoints,
  });

  AnalyticsOverview copyWith({
    List<StudyGoal>? activeGoals,
    List<AnalyticsInsight>? insights,
    ProgressSnapshot? todaySnapshot,
    Map<String, double>? subjectDistribution,
    Map<String, int>? taskDistribution,
    Map<DateTime, int>? studyHeatmap,
    double? averageSessionDuration,
    int? bestFocusHour,
    int? totalPoints,
  }) {
    return AnalyticsOverview(
      snapshot: snapshot,
      todaySnapshot: todaySnapshot ?? this.todaySnapshot,
      trends: trends,
      activeGoals: activeGoals ?? this.activeGoals,
      insights: insights ?? this.insights,
      subjectDistribution: subjectDistribution ?? this.subjectDistribution,
      taskDistribution: taskDistribution ?? this.taskDistribution,
      studyHeatmap: studyHeatmap ?? this.studyHeatmap,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      bestFocusHour: bestFocusHour ?? this.bestFocusHour,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  @override
  List<Object?> get props => [
    snapshot,
    todaySnapshot,
    trends,
    activeGoals,
    insights,
    subjectDistribution,
    taskDistribution,
    studyHeatmap,
    averageSessionDuration,
    bestFocusHour,
    totalPoints,
  ];
}
