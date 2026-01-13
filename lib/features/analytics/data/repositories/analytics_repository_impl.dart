import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/features/analytics/data/services/analytics_ai_service.dart';
import 'package:smart_study_plan/features/analytics/data/services/goal_progress_service.dart';
import 'package:smart_study_plan/features/analytics/domain/entities/analytics_insight.dart';
import 'package:smart_study_plan/features/analytics/domain/enums/goal_status.dart';
import 'package:smart_study_plan/features/analytics/domain/enums/insight_type.dart';

import '../../../../core/error/failures.dart';

import '../../domain/entities/analytics_overview.dart';
import '../../domain/entities/study_goal.dart';
import '../../domain/repositories/analytics_repository.dart';

import '../datasources/analytics_local_datasource.dart';
import '../datasources/analytics_remote_datasource.dart';

import '../models/progress_snapshot_model.dart';
import '../models/progress_trends_model.dart';
import '../models/analytics_insight_model.dart';
import '../models/study_goal_model.dart';

import '../services/analytics_service.dart';

import '../../../../features/tasks/domain/entities/task.dart';
import '../../../../features/tasks/domain/repositories/task_repository.dart';

import '../../../../features/planner/domain/entities/study_session.dart';
import '../../../../features/planner/domain/repositories/planner_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;
  final AnalyticsRemoteDataSource remoteDataSource;
  final TaskRepository taskRepository;
  final PlannerRepository plannerRepository;
  final AnalyticsAiService analyticsAiService;

  AnalyticsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.taskRepository,
    required this.plannerRepository,
    required this.analyticsAiService,
  });

  // ---------------------------------------------------------------------------
  // ANALYTICS OVERVIEW
  // ---------------------------------------------------------------------------
  @override
  Future<Either<Failure, AnalyticsOverview>> loadOverview({
    required String userId,
    DateTime? start,
    DateTime? end,
  }) async {
    // -----------------------------------------------------------------------
    // 1️⃣ TRY LOCAL CACHE
    // -----------------------------------------------------------------------
    final cachedResult = await localDataSource.getOverview();

    if (cachedResult.isRight()) {
      final cached = cachedResult.getOrElse(
        () => throw StateError('Invalid cache state'),
      );

      return Right(
        AnalyticsOverview(
          snapshot: cached.snapshot.toEntity(),
          trends: cached.trends.toEntity(),
          activeGoals: const [],
          insights: cached.insights.map((i) => i.toEntity()).toList(),
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 2️⃣ FETCH REQUIRED DATA
    // -----------------------------------------------------------------------
    final tasksResult = await taskRepository.getTasksByUser(userId);
    final sessionsResult = await plannerRepository.getSessionsByUser(userId);
    final goalsResult = await remoteDataSource.fetchGoals(userId);

    // -----------------------------------------------------------------------
    // 3️⃣ HANDLE FAILURES (NO cast())
    // -----------------------------------------------------------------------
    if (tasksResult.isLeft()) {
      return Left(
        tasksResult.swap().getOrElse(
          () => const UnknownFailure('Failed to load tasks'),
        ),
      );
    }

    if (sessionsResult.isLeft()) {
      return Left(
        sessionsResult.swap().getOrElse(
          () => const UnknownFailure('Failed to load sessions'),
        ),
      );
    }

    if (goalsResult.isLeft()) {
      return Left(
        goalsResult.swap().getOrElse(
          () => const UnknownFailure('Failed to load goals'),
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 4️⃣ EXTRACT DATA (NO GENERICS BUG)
    // -----------------------------------------------------------------------
    final List<Task> tasks = tasksResult.getOrElse(() => <Task>[]);

    final List<StudySession> sessions = sessionsResult.getOrElse(
      () => <StudySession>[],
    );

    final List<StudyGoal> goals = goalsResult
        .getOrElse(() => <StudyGoalModel>[])
        .map((g) => g.toEntity())
        .toList();

    // -----------------------------------------------------------------------
    // 5️⃣ BUILD ANALYTICS OVERVIEW
    // -----------------------------------------------------------------------
    final analyticsResult = AnalyticsService.buildOverview(
      start: start ?? DateTime.now().subtract(const Duration(days: 6)),
      end: end ?? DateTime.now(),
      tasks: tasks,
      sessions: sessions,
      activeGoals: goals,
    );

    if (analyticsResult.isLeft()) {
      return analyticsResult;
    }

    final overview = analyticsResult.getOrElse(
      () => throw StateError('Invalid analytics state'),
    );

    // -----------------------------------------------------------------------
    // 5️⃣.5️⃣ AI INSIGHTS (STEP 8 ✔)
    // -----------------------------------------------------------------------
    final summaryText = _buildAnalyticsSummary(
      tasks: tasks,
      sessions: sessions,
      overview: overview,
    );

    final aiInsightResult = await analyticsAiService.generateInsight(
      summaryText,
    );

    final aiInsights = aiInsightResult.fold(
      (_) => <AnalyticsInsight>[],
      (text) => [
        AnalyticsInsight(
          message: text,
          type: InsightType.ai, // ✅ already in your enum
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // 6️⃣ AUTO-UPDATE GOALS (STEP 6 ✔)
    // -----------------------------------------------------------------------
    final updatedGoals = goals.map((goal) {
      final progress = GoalProgressService.calculateProgress(
        goal: goal,
        tasks: tasks,
        sessions: sessions,
        currentStreak: overview.trends.studyStreak,
      );

      return goal.copyWith(
        progress: progress,
        status: progress >= goal.targetValue
            ? GoalStatus.completed
            : goal.status,
      );
    }).toList();

    await localDataSource.saveGoals(
      updatedGoals.map(StudyGoalModel.fromEntity).toList(),
    );

    // -----------------------------------------------------------------------
    // 7️⃣ SAVE ANALYTICS CACHE
    // -----------------------------------------------------------------------
    final mergedInsights = [...overview.insights, ...aiInsights];

    await localDataSource.saveOverview(
      snapshot: ProgressSnapshotModel.fromEntity(overview.snapshot),
      trends: ProgressTrendsModel.fromEntity(overview.trends),
      insights: mergedInsights
          .map((i) => AnalyticsInsightModel.fromEntity(i))
          .toList(),
    );

    // -----------------------------------------------------------------------
    // 8️⃣ REMOTE SYNC (BEST-EFFORT)
    // -----------------------------------------------------------------------
    try {
      await remoteDataSource.saveOverview(
        userId: userId,
        snapshot: ProgressSnapshotModel.fromEntity(overview.snapshot),
        trends: ProgressTrendsModel.fromEntity(overview.trends),
        insights: overview.insights
            .map((i) => AnalyticsInsightModel.fromEntity(i))
            .toList(),
      );
    } catch (_) {
      // ignore – offline safe
    }

    return Right(
      overview.copyWith(
        activeGoals: updatedGoals,
        insights: mergedInsights, // ✅ AI INCLUDED
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GOALS
  // ---------------------------------------------------------------------------
  @override
  Future<Either<Failure, void>> createGoal(StudyGoal goal) async {
    try {
      await localDataSource.saveGoals([StudyGoalModel.fromEntity(goal)]);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Create goal failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGoal(StudyGoal goal) async {
    try {
      await localDataSource.saveGoals([StudyGoalModel.fromEntity(goal)]);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Update goal failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String goalId) async {
    try {
      await localDataSource.deleteGoal(goalId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Delete goal failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGoal>>> getActiveGoals(String userId) async {
    final result = await localDataSource.getActiveGoals(userId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}

String _buildAnalyticsSummary({
  required List<Task> tasks,
  required List<StudySession> sessions,
  required AnalyticsOverview overview,
}) {
  final completed = tasks.where((t) => t.isCompleted).length;
  final overdue = tasks
      .where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now()))
      .length;

  return '''
Study period: ${overview.snapshot.periodStart} to ${overview.snapshot.periodEnd}

Tasks:
- Total: ${tasks.length}
- Completed: $completed
- Overdue: $overdue

Study:
- Total hours: ${overview.snapshot.totalStudyHours.toStringAsFixed(1)}
- Sessions: ${overview.snapshot.sessionCount}
- Current streak: ${overview.trends.studyStreak} days
''';
}
