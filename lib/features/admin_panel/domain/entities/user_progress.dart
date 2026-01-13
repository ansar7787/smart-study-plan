import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  final String userId;

  final int subjectsCount;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  final int totalStudyMinutes;
  final int currentStreak;
  final int longestStreak;

  final DateTime lastActiveAt;
  final DateTime updatedAt;

  const UserProgress({
    required this.userId,
    required this.subjectsCount,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.totalStudyMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveAt,
    required this.updatedAt,
  });

  /// % completion
  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  /// Admin warning flag
  bool get isInactive => DateTime.now().difference(lastActiveAt).inDays >= 7;

  @override
  List<Object?> get props => [userId, updatedAt];
}
