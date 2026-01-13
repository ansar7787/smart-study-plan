import '../../domain/entities/study_goal.dart';
import '../../domain/enums/goal_metric_type.dart';
import '../../../../features/tasks/domain/entities/task.dart';
import '../../../../features/planner/domain/entities/study_session.dart';

class GoalProgressService {
  static double calculateProgress({
    required StudyGoal goal,
    required List<Task> tasks,
    required List<StudySession> sessions,
    required int currentStreak,
  }) {
    switch (goal.metricType) {
      case GoalMetricType.completedTasks:
        return tasks.where((t) => t.isCompleted).length.toDouble();

      case GoalMetricType.studyHours:
        return sessions.fold(0.0, (sum, s) => sum + s.duration.inMinutes / 60);

      case GoalMetricType.studyStreak:
        return currentStreak.toDouble();
    }
  }

  static bool isCompleted(StudyGoal goal) {
    return goal.progress >= goal.targetValue;
  }
}
