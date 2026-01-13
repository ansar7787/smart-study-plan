import '../../domain/entities/user_progress.dart';

class UserProgressModel {
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

  UserProgressModel({
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

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['userId'],
      subjectsCount: json['subjectsCount'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActiveAt: DateTime.parse(json['lastActiveAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'subjectsCount': subjectsCount,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'totalStudyMinutes': totalStudyMinutes,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProgress toEntity() {
    return UserProgress(
      userId: userId,
      subjectsCount: subjectsCount,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      totalStudyMinutes: totalStudyMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveAt: lastActiveAt,
      updatedAt: updatedAt,
    );
  }
}
