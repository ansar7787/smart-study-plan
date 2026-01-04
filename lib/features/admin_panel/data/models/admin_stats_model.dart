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
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalAdmins: json['totalAdmins'] as int? ?? 0,
      totalSubjects: json['totalSubjects'] as int? ?? 0,
      totalTasks: json['totalTasks'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
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

  factory AdminStatsModel.fromEntity(AdminStats stats) {
    return AdminStatsModel(
      totalUsers: stats.totalUsers,
      totalStudents: stats.totalStudents,
      totalAdmins: stats.totalAdmins,
      totalSubjects: stats.totalSubjects,
      totalTasks: stats.totalTasks,
      lastUpdated: stats.lastUpdated,
    );
  }
}
