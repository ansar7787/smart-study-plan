import 'package:equatable/equatable.dart';
import '../enums/goal_metric_type.dart';
import '../enums/goal_status.dart';

class StudyGoal extends Equatable {
  final String id;
  final String userId;

  final String title;
  final String description;

  final GoalMetricType metricType;
  final double targetValue;
  final double progress;

  final DateTime startDate;
  final DateTime endDate;

  final GoalStatus status;

  const StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.metricType,
    required this.targetValue,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  // ✅ FIXED copyWith (NO timestamps)
  StudyGoal copyWith({double? progress, GoalStatus? status}) {
    return StudyGoal(
      id: id,
      userId: userId,
      title: title,
      description: description,
      metricType: metricType,
      targetValue: targetValue,
      progress: progress ?? this.progress,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
    );
  }

  double get completionPercentage =>
      targetValue == 0 ? 0 : (progress / targetValue) * 100;

  bool get isActive =>
      status == GoalStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    metricType,
    targetValue,
    progress,
    startDate,
    endDate,
    status,
  ];
}
