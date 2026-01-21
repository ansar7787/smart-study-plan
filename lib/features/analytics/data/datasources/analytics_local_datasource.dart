import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../models/progress_snapshot_model.dart';
import '../models/progress_trends_model.dart';
import '../models/analytics_insight_model.dart';
import '../models/study_goal_model.dart';

abstract class AnalyticsLocalDataSource {
  Future<Either<Failure, void>> saveOverview({
    required ProgressSnapshotModel snapshot,
    required ProgressSnapshotModel todaySnapshot, // ✅ NEW
    required ProgressTrendsModel trends,
    required List<AnalyticsInsightModel> insights,
  });

  Future<
    Either<
      Failure,
      ({
        ProgressSnapshotModel snapshot,
        ProgressSnapshotModel todaySnapshot, // ✅ NEW
        ProgressTrendsModel trends,
        List<AnalyticsInsightModel> insights,
      })
    >
  >
  getOverview();

  Future<Either<Failure, List<StudyGoalModel>>> getActiveGoals(String userId);

  Future<Either<Failure, void>> saveGoals(List<StudyGoalModel> goals);
  Future<void> deleteGoal(String goalId);
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  static const _overviewBox = 'analytics_overview';
  static const _goalsBox = 'study_goals';

  @override
  Future<Either<Failure, void>> saveOverview({
    required ProgressSnapshotModel snapshot,
    required ProgressSnapshotModel todaySnapshot, // ✅ NEW
    required ProgressTrendsModel trends,
    required List<AnalyticsInsightModel> insights,
  }) async {
    try {
      final box = await Hive.openBox(_overviewBox);
      await box.put('snapshot', snapshot);
      await box.put('today_snapshot', todaySnapshot);
      await box.put('trends', trends);
      await box.put('insights', insights);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache analytics: $e'));
    }
  }

  @override
  Future<
    Either<
      Failure,
      ({
        ProgressSnapshotModel snapshot,
        ProgressSnapshotModel todaySnapshot, // ✅ NEW
        ProgressTrendsModel trends,
        List<AnalyticsInsightModel> insights,
      })
    >
  >
  getOverview() async {
    try {
      final box = await Hive.openBox(_overviewBox);

      final snapshot = box.get('snapshot');
      final todaySnapshot = box.get('today_snapshot');
      final trends = box.get('trends');
      final insights = box.get('insights');

      if (snapshot == null ||
          todaySnapshot == null ||
          trends == null ||
          insights == null) {
        return Left(CacheFailure('No cached analytics data'));
      }

      return Right((
        snapshot: snapshot as ProgressSnapshotModel,
        todaySnapshot: todaySnapshot as ProgressSnapshotModel,
        trends: trends as ProgressTrendsModel,
        insights: List<AnalyticsInsightModel>.from(insights as List),
      ));
    } catch (e) {
      return Left(CacheFailure('Failed to load cached analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGoalModel>>> getActiveGoals(
    String userId,
  ) async {
    try {
      final box = await Hive.openBox<StudyGoalModel>(_goalsBox);
      final now = DateTime.now();

      final goals = box.values
          .where(
            (g) =>
                g.userId == userId &&
                g.startDate.isBefore(now) &&
                g.endDate.isAfter(now) &&
                g.status.name == 'active',
          )
          .toList();

      return Right(goals);
    } catch (e) {
      return Left(CacheFailure('Failed to load goals: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGoals(List<StudyGoalModel> goals) async {
    try {
      final box = await Hive.openBox<StudyGoalModel>(_goalsBox);
      for (final goal in goals) {
        await box.put(goal.id, goal);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save goals: $e'));
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final box = await Hive.openBox<StudyGoalModel>('study_goals');
    await box.delete(goalId);
  }
}
