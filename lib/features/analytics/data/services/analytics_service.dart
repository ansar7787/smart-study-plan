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

      // 1. FILTER FOR PERIOD (Week/Month)
      final filteredTasks = tasks.where(
        (t) => t.dueDate.isAfter(start) && t.dueDate.isBefore(end),
      );
      final filteredSessions = sessions.where(
        (s) => s.startTime.isAfter(start) && s.startTime.isBefore(end),
      );

      // 2. PERIOD SNAPSHOT
      final snapshot = _buildSnapshot(
        start: start,
        end: end,
        tasks: tasks, // ✅ Use ALL tasks for global stats
        sessions: filteredSessions,
      );

      // 3. TODAY SNAPSHOT
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayTasks = tasks.where(
        (t) => t.dueDate.isAfter(todayStart) && t.dueDate.isBefore(todayEnd),
      );
      final todaySessions = sessions.where(
        (s) =>
            s.startTime.isAfter(todayStart) && s.startTime.isBefore(todayEnd),
      );

      final todaySnapshot = _buildSnapshot(
        start: todayStart,
        end: todayEnd,
        tasks: todayTasks,
        sessions: todaySessions,
      );

      // 4. TRENDS (Use period data)
      final trends = ProgressTrends(
        dailyStudyHours: _dailyStudyHours(filteredSessions.toList(), end),
        dailyTaskCompletion: _dailyTaskCompletion(filteredTasks.toList(), end),
        // ✅ FIXED: Streak uses FULL history, not just period
        studyStreak: _calculateStreak(tasks, sessions),
      );

      // 5. INSIGHTS
      final insights = _generateInsights(snapshot, trends);

      // 6. SUBJECT DISTRIBUTION (Time)
      final subjectDistribution = _calculateSubjectDistribution(
        filteredSessions.toList(),
      );

      // 7. TASK DISTRIBUTION (Count)
      final taskDistribution = _calculateTaskDistribution(tasks.toList());

      // 8. HEATMAP (Global)
      final studyHeatmap = _calculateStudyHeatmap(sessions);

      // 9. FOCUS ANALYSIS (Global)
      final bestFocusHour = _calculateBestFocusHour(sessions);
      final averageSessionDuration = _calculateGlobalAverageDuration(sessions);

      // 10. GAMIFICATION (XP)
      final totalPoints = _calculateTotalPoints(tasks, sessions);

      return Right(
        AnalyticsOverview(
          snapshot: snapshot,
          todaySnapshot: todaySnapshot,
          trends: trends,
          activeGoals: activeGoals,
          insights: insights,
          subjectDistribution: subjectDistribution,
          taskDistribution: taskDistribution,
          studyHeatmap: studyHeatmap,
          averageSessionDuration: averageSessionDuration,
          bestFocusHour: bestFocusHour,
          totalPoints: totalPoints,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Analytics error: $e'));
    }
  }

  // ================= HELPERS =================

  static int _calculateTotalPoints(
    List<Task> tasks,
    List<StudySession> sessions,
  ) {
    int points = 0;

    // 10 XP per completed task
    points += tasks.where((t) => t.isCompleted).length * 10;

    // 1 XP per minute studied
    final minutes = sessions.fold(0, (sum, s) => sum + s.duration.inMinutes);
    points += minutes;

    return points;
  }

  static Map<DateTime, int> _calculateStudyHeatmap(
    List<StudySession> sessions,
  ) {
    final heatmap = <DateTime, int>{};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final minutes = session.duration.inMinutes;
      heatmap.update(date, (value) => value + minutes, ifAbsent: () => minutes);
    }
    return heatmap;
  }

  static int _calculateBestFocusHour(List<StudySession> sessions) {
    if (sessions.isEmpty) return 9; // Default to 9 AM

    final hourCounts = <int, int>{};

    for (final session in sessions) {
      // We credit the starting hour
      final hour = session.startTime.hour;
      hourCounts.update(hour, (val) => val + 1, ifAbsent: () => 1);
    }

    var bestHour = 9;
    var maxCount = -1;

    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        bestHour = hour;
      }
    });

    return bestHour;
  }

  static double _calculateGlobalAverageDuration(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0.0;
    final totalMinutes = sessions.fold(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );
    return totalMinutes / sessions.length;
  }

  static Map<String, int> _calculateTaskDistribution(List<Task> tasks) {
    final distribution = <String, int>{};
    for (final task in tasks) {
      distribution.update(
        task.subjectId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return distribution;
  }

  static Map<String, double> _calculateSubjectDistribution(
    List<StudySession> sessions,
  ) {
    final distribution = <String, double>{};

    for (final session in sessions) {
      final hours = session.duration.inMinutes / 60.0;
      if (hours > 0) {
        final subjectId = session.subjectId ?? 'Unknown';

        distribution.update(
          subjectId,
          (value) => value + hours,
          ifAbsent: () => hours,
        );
      }
    }
    return distribution;
  }

  static ProgressSnapshot _buildSnapshot({
    required DateTime start,
    required DateTime end,
    required Iterable<Task> tasks,
    required Iterable<StudySession> sessions,
  }) {
    return ProgressSnapshot(
      periodStart: start,
      periodEnd: end,
      totalTasks: tasks.length,
      completedTasks: tasks.where((t) => t.isCompleted).length,
      overdueTasks: tasks.where((t) => !t.isCompleted).length,
      totalStudyHours: sessions.fold(
        0,
        (sum, s) => sum + s.duration.inMinutes / 60,
      ),
      sessionCount: sessions.length,
    );
  }

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
        // Allow missing today if checked early in the morning
        if (i == 0 && streak == 0) continue;
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

    if (snapshot.completionRate < 0.5 && snapshot.totalTasks > 0) {
      insights.add(
        AnalyticsInsight(
          message:
              'You are completing less than half of your tasks. Try reducing workload.',
          type: InsightType.warning,
        ),
      );
    }

    if (trends.studyStreak >= 3) {
      insights.add(
        AnalyticsInsight(
          message: 'Great job! ${trends.studyStreak}-day study streak 🔥',
          type: InsightType.success,
        ),
      );
    }

    if (snapshot.averageSessionDuration < 0.5 && snapshot.sessionCount > 0) {
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
