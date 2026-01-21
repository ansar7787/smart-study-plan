import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/features/analytics/domain/entities/study_goal.dart';
import '../../domain/enums/goal_metric_type.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  final String userId;
  final DateTime? start;
  final DateTime? end;

  const LoadAnalyticsEvent({required this.userId, this.start, this.end});

  @override
  List<Object?> get props => [userId, start, end];
}

class CreateStudyGoalEvent extends AnalyticsEvent {
  final String userId;
  final String title;
  final String description;
  final GoalMetricType metricType; // ✅ REQUIRED
  final double targetValue;
  final DateTime startDate;
  final DateTime endDate;

  const CreateStudyGoalEvent({
    required this.userId,
    required this.title,
    required this.description,
    required this.metricType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
    userId,
    title,
    description,
    metricType,
    targetValue,
    startDate,
    endDate,
  ];
}

class UpdateStudyGoalEvent extends AnalyticsEvent {
  final StudyGoal goal; // ✅ FIXED

  const UpdateStudyGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteStudyGoalEvent extends AnalyticsEvent {
  final String goalId;
  final String userId;

  const DeleteStudyGoalEvent({required this.goalId, required this.userId});

  @override
  List<Object?> get props => [goalId, userId];
}
