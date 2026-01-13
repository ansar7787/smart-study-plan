import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_overview.dart';
import '../entities/study_goal.dart';

abstract class AnalyticsRepository {
  /// Loads full analytics dashboard data
  Future<Either<Failure, AnalyticsOverview>> loadOverview({
    required String userId,
    DateTime? start,
    DateTime? end,
  });

  /// Goals
  Future<Either<Failure, void>> createGoal(StudyGoal goal);
  Future<Either<Failure, void>> updateGoal(StudyGoal goal);
  Future<Either<Failure, void>> deleteGoal(String goalId);

  Future<Either<Failure, List<StudyGoal>>> getActiveGoals(String userId);
}
