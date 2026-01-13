import '../../domain/entities/admin_stats.dart';

class AdminStatsModel {
  final int totalUsers;
  final int totalStudents;
  final int totalAdmins;
  final int totalSubjects;
  final int totalTasks;
  final DateTime lastUpdated;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalAdmins,
    required this.totalSubjects,
    required this.totalTasks,
    required this.lastUpdated,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalAdmins: json['totalAdmins'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalStudents': totalStudents,
      'totalAdmins': totalAdmins,
      'totalSubjects': totalSubjects,
      'totalTasks': totalTasks,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  AdminStats toEntity() {
    return AdminStats(
      totalUsers: totalUsers,
      totalStudents: totalStudents,
      totalAdmins: totalAdmins,
      totalSubjects: totalSubjects,
      totalTasks: totalTasks,
      lastUpdated: lastUpdated,
    );
  }
}
