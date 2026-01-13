import 'package:equatable/equatable.dart';
import 'progress_snapshot.dart';
import 'progress_trends.dart';
import 'analytics_insight.dart';
import 'study_goal.dart';

class AnalyticsOverview extends Equatable {
  final ProgressSnapshot snapshot;
  final ProgressTrends trends;
  final List<StudyGoal> activeGoals;
  final List<AnalyticsInsight> insights;

  const AnalyticsOverview({
    required this.snapshot,
    required this.trends,
    required this.activeGoals,
    required this.insights,
  });

  // ✅ FIXED: support insights too
  AnalyticsOverview copyWith({
    List<StudyGoal>? activeGoals,
    List<AnalyticsInsight>? insights,
  }) {
    return AnalyticsOverview(
      snapshot: snapshot,
      trends: trends,
      activeGoals: activeGoals ?? this.activeGoals,
      insights: insights ?? this.insights,
    );
  }

  @override
  List<Object?> get props => [snapshot, trends, activeGoals, insights];
}
