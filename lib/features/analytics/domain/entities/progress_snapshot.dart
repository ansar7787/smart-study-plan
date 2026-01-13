import 'package:equatable/equatable.dart';

class ProgressSnapshot extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;

  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;

  final double totalStudyHours;
  final int sessionCount;

  const ProgressSnapshot({
    required this.periodStart,
    required this.periodEnd,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.totalStudyHours,
    required this.sessionCount,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  double get completionPercentage => completionRate * 100;

  double get averageSessionDuration =>
      sessionCount == 0 ? 0 : totalStudyHours / sessionCount;

  @override
  List<Object?> get props => [
    periodStart,
    periodEnd,
    totalTasks,
    completedTasks,
    overdueTasks,
    totalStudyHours,
    sessionCount,
  ];
}
