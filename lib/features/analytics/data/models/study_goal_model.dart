import 'package:hive/hive.dart';
import '../../domain/entities/study_goal.dart';
import '../../domain/enums/goal_metric_type.dart';
import '../../domain/enums/goal_status.dart';

part 'study_goal_model.g.dart';

@HiveType(typeId: 11)
class StudyGoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final GoalMetricType metricType;

  @HiveField(5)
  final double targetValue;

  @HiveField(6)
  final double progress;

  @HiveField(7)
  final DateTime startDate;

  @HiveField(8)
  final DateTime endDate;

  @HiveField(9)
  final GoalStatus status;

  StudyGoalModel({
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

  StudyGoal toEntity() => StudyGoal(
    id: id,
    userId: userId,
    title: title,
    description: description,
    metricType: metricType,
    targetValue: targetValue,
    progress: progress,
    startDate: startDate,
    endDate: endDate,
    status: status,
  );

  factory StudyGoalModel.fromEntity(StudyGoal e) => StudyGoalModel(
    id: e.id,
    userId: e.userId,
    title: e.title,
    description: e.description,
    metricType: e.metricType,
    targetValue: e.targetValue,
    progress: e.progress,
    startDate: e.startDate,
    endDate: e.endDate,
    status: e.status,
  );
}
