import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/analytics/domain/enums/goal_metric_type.dart';
import 'package:smart_study_plan/features/analytics/domain/enums/goal_status.dart';
import '../../../../core/error/failures.dart';
import '../models/progress_snapshot_model.dart';
import '../models/progress_trends_model.dart';
import '../models/analytics_insight_model.dart';
import '../models/study_goal_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<Either<Failure, void>> saveOverview({
    required String userId,
    required ProgressSnapshotModel snapshot,
    required ProgressTrendsModel trends,
    required List<AnalyticsInsightModel> insights,
  });

  Future<Either<Failure, List<StudyGoalModel>>> fetchGoals(String userId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;

  AnalyticsRemoteDataSourceImpl(this.firestore);

  @override
  Future<Either<Failure, void>> saveOverview({
    required String userId,
    required ProgressSnapshotModel snapshot,
    required ProgressTrendsModel trends,
    required List<AnalyticsInsightModel> insights,
  }) async {
    try {
      await firestore.collection('analytics').doc(userId).set({
        'snapshot': {
          'periodStart': snapshot.periodStart.toIso8601String(),
          'periodEnd': snapshot.periodEnd.toIso8601String(),
          'totalTasks': snapshot.totalTasks,
          'completedTasks': snapshot.completedTasks,
          'overdueTasks': snapshot.overdueTasks,
          'totalStudyHours': snapshot.totalStudyHours,
          'sessionCount': snapshot.sessionCount,
        },
        'trends': {
          'dailyStudyHours': trends.dailyStudyHours,
          'dailyTaskCompletion': trends.dailyTaskCompletion,
          'studyStreak': trends.studyStreak,
        },
        'insights': insights
            .map((i) => {'message': i.message, 'type': i.type.name})
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGoalModel>>> fetchGoals(
    String userId,
  ) async {
    try {
      final snap = await firestore
          .collection('study_goals')
          .where('userId', isEqualTo: userId)
          .get();

      final goals = snap.docs.map((doc) {
        final data = doc.data();
        return StudyGoalModel(
          id: doc.id,
          userId: data['userId'],
          title: data['title'],
          description: data['description'],
          metricType: GoalMetricType.values.byName(data['metricType']),
          targetValue: (data['targetValue'] as num).toDouble(),
          progress: (data['progress'] as num).toDouble(),
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          status: GoalStatus.values.byName(data['status']),
        );
      }).toList();

      return Right(goals);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch goals: $e'));
    }
  }
}
