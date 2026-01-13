import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/features/analytics/domain/entities/study_goal.dart';
import 'package:smart_study_plan/features/tasks/domain/entities/task.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/progress_snapshot.dart';
import '../../domain/entities/progress_trends.dart';
import '../../domain/entities/analytics_insight.dart';
import '../../domain/entities/analytics_overview.dart';
import '../../domain/enums/insight_type.dart';
import '../../../../features/planner/domain/entities/study_session.dart';

class AnalyticsService {
  static Either<Failure, AnalyticsOverview> buildOverview({
    required DateTime start,
    required DateTime end,
    required List<Task> tasks,
    required List<StudySession> sessions,
    required List<StudyGoal> activeGoals,
  }) {
    try {
      if (end.isBefore(start)) {
        return Left(ValidationFailure('End date must be after start date'));
      }

      final filteredTasks = tasks.where(
        (t) => t.dueDate.isAfter(start) && t.dueDate.isBefore(end),
      );

      final filteredSessions = sessions.where(
        (s) => s.startTime.isAfter(start) && s.startTime.isBefore(end),
      );

      // ---------- SNAPSHOT ----------
      final snapshot = ProgressSnapshot(
        periodStart: start,
        periodEnd: end,
        totalTasks: filteredTasks.length,
        completedTasks: filteredTasks.where((t) => t.isCompleted).length,
        overdueTasks: filteredTasks.where((t) => !t.isCompleted).length,
        totalStudyHours: filteredSessions.fold(
          0,
          (sum, s) => sum + s.duration.inMinutes / 60,
        ),
        sessionCount: filteredSessions.length,
      );

      // ---------- TRENDS ----------
      final trends = ProgressTrends(
        dailyStudyHours: _dailyStudyHours(filteredSessions.toList(), end),
        dailyTaskCompletion: _dailyTaskCompletion(filteredTasks.toList(), end),
        studyStreak: _calculateStreak(
          filteredTasks.toList(),
          filteredSessions.toList(),
        ),
      );

      // ---------- INSIGHTS ----------
      final insights = _generateInsights(snapshot, trends);

      return Right(
        AnalyticsOverview(
          snapshot: snapshot,
          trends: trends,
          activeGoals: activeGoals,
          insights: insights,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Analytics error: $e'));
    }
  }

  // ================= HELPERS =================

  static List<double> _dailyStudyHours(
    List<StudySession> sessions,
    DateTime end,
  ) {
    return List.generate(7, (i) {
      final day = end.subtract(Duration(days: 6 - i));
      return sessions
          .where((s) => _sameDay(s.startTime, day))
          .fold(0.0, (sum, s) => sum + s.duration.inMinutes / 60);
    });
  }

  static List<double> _dailyTaskCompletion(List<Task> tasks, DateTime end) {
    return List.generate(7, (i) {
      final day = end.subtract(Duration(days: 6 - i));
      final dayTasks = tasks.where((t) => _sameDay(t.dueDate, day));
      if (dayTasks.isEmpty) return 0.0;
      final completed = dayTasks.where((t) => t.isCompleted).length;
      return completed / dayTasks.length;
    });
  }

  static int _calculateStreak(List<Task> tasks, List<StudySession> sessions) {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final day = DateTime(today.year, today.month, today.day - i);

      final hasTask = tasks.any(
        (t) => t.isCompleted && _sameDay(t.updatedAt, day),
      );

      final hasSession = sessions.any((s) => _sameDay(s.startTime, day));

      if (hasTask || hasSession) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  static List<AnalyticsInsight> _generateInsights(
    ProgressSnapshot snapshot,
    ProgressTrends trends,
  ) {
    final insights = <AnalyticsInsight>[];

    if (snapshot.completionRate < 0.5) {
      insights.add(
        AnalyticsInsight(
          message:
              'You are completing less than half of your tasks. Try reducing workload.',
          type: InsightType.warning,
        ),
      );
    }

    if (trends.studyStreak >= 5) {
      insights.add(
        AnalyticsInsight(
          message: 'Great job! ${trends.studyStreak}-day study streak 🔥',
          type: InsightType.success,
        ),
      );
    }

    if (snapshot.averageSessionDuration < 0.5) {
      insights.add(
        AnalyticsInsight(
          message: 'Short study sessions detected. Try 25–45 minute sessions.',
          type: InsightType.tip,
        ),
      );
    }

    return insights;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
