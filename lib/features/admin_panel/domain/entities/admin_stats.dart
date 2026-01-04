import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int totalStudents;
  final int totalAdmins;
  final int totalSubjects;
  final int totalTasks;
  final DateTime lastUpdated;

  const AdminStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalAdmins,
    required this.totalSubjects,
    required this.totalTasks,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalStudents,
    totalAdmins,
    totalSubjects,
    totalTasks,
    lastUpdated,
  ];
}
