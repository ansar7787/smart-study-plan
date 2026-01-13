import 'package:hive/hive.dart';
import '../../domain/entities/progress_snapshot.dart';

part 'progress_snapshot_model.g.dart';

@HiveType(typeId: 8)
class ProgressSnapshotModel extends HiveObject {
  @HiveField(0)
  final DateTime periodStart;

  @HiveField(1)
  final DateTime periodEnd;

  @HiveField(2)
  final int totalTasks;

  @HiveField(3)
  final int completedTasks;

  @HiveField(4)
  final int overdueTasks;

  @HiveField(5)
  final double totalStudyHours;

  @HiveField(6)
  final int sessionCount;

  ProgressSnapshotModel({
    required this.periodStart,
    required this.periodEnd,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.totalStudyHours,
    required this.sessionCount,
  });

  ProgressSnapshot toEntity() => ProgressSnapshot(
    periodStart: periodStart,
    periodEnd: periodEnd,
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    overdueTasks: overdueTasks,
    totalStudyHours: totalStudyHours,
    sessionCount: sessionCount,
  );

  factory ProgressSnapshotModel.fromEntity(ProgressSnapshot e) =>
      ProgressSnapshotModel(
        periodStart: e.periodStart,
        periodEnd: e.periodEnd,
        totalTasks: e.totalTasks,
        completedTasks: e.completedTasks,
        overdueTasks: e.overdueTasks,
        totalStudyHours: e.totalStudyHours,
        sessionCount: e.sessionCount,
      );
}
