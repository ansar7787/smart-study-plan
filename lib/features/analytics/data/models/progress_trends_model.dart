import 'package:hive/hive.dart';
import '../../domain/entities/progress_trends.dart';

part 'progress_trends_model.g.dart';

@HiveType(typeId: 9)
class ProgressTrendsModel extends HiveObject {
  @HiveField(0)
  final List<double> dailyStudyHours;

  @HiveField(1)
  final List<double> dailyTaskCompletion;

  @HiveField(2)
  final int studyStreak;

  ProgressTrendsModel({
    required this.dailyStudyHours,
    required this.dailyTaskCompletion,
    required this.studyStreak,
  });

  ProgressTrends toEntity() => ProgressTrends(
    dailyStudyHours: dailyStudyHours,
    dailyTaskCompletion: dailyTaskCompletion,
    studyStreak: studyStreak,
  );

  factory ProgressTrendsModel.fromEntity(ProgressTrends e) =>
      ProgressTrendsModel(
        dailyStudyHours: e.dailyStudyHours,
        dailyTaskCompletion: e.dailyTaskCompletion,
        studyStreak: e.studyStreak,
      );
}
