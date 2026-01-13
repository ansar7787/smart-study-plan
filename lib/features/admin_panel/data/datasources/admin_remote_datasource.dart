import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

import '../models/admin_stats_model.dart';
import '../models/user_admin_model.dart';

abstract class AdminRemoteDatasource {
  // USERS
  Future<List<UserAdminModel>> getAllUsers();
  Future<List<UserAdminModel>> getUsersByRole(String role);

  Future<void> deleteUser(String userId);
  Future<void> updateUserRole(String userId, String newRole);

  // STATS
  Future<AdminStatsModel> getAdminStats();

  // SEARCH
  Future<List<UserAdminModel>> searchUsers(String query);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final FirebaseFirestore firestore;

  AdminRemoteDatasourceImpl(this.firestore);

  // ------------------------------------------------------------
  // USERS
  // ------------------------------------------------------------

  @override
  Future<List<UserAdminModel>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();

      final users = snapshot.docs
          .map((doc) => UserAdminModel.fromJson(doc.data()))
          .toList();

      AppLogger.d('Fetched ${users.length} users from Firestore');
      return users;
    } catch (e) {
      throw AuthFirebaseException('Failed to fetch users: $e');
    }
  }

  @override
  Future<List<UserAdminModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      final users = snapshot.docs
          .map((doc) => UserAdminModel.fromJson(doc.data()))
          .toList();

      AppLogger.d('Fetched ${users.length} users with role=$role');
      return users;
    } catch (e) {
      throw AuthFirebaseException('Failed to fetch users by role: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).delete();
      AppLogger.d('User deleted: $userId');
    } catch (e) {
      throw AuthFirebaseException('Failed to delete user: $e');
    }
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      AppLogger.d('User role updated: $userId → $newRole');
    } catch (e) {
      throw AuthFirebaseException('Failed to update user role: $e');
    }
  }

  // ------------------------------------------------------------
  // STATS
  // ------------------------------------------------------------

  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      final usersSnapshot = await firestore.collection('users').get();

      int students = 0;
      int admins = 0;

      for (final doc in usersSnapshot.docs) {
        final role = doc.data()['role'];
        if (role == 'student') students++;
        if (role == 'admin') admins++;
      }

      final stats = AdminStatsModel(
        totalUsers: usersSnapshot.docs.length,
        totalStudents: students,
        totalAdmins: admins,
        totalSubjects: 0, // will be updated later
        totalTasks: 0, // will be updated later
        lastUpdated: DateTime.now(),
      );

      AppLogger.d('Admin stats calculated');
      return stats;
    } catch (e) {
      throw AuthFirebaseException('Failed to load admin stats: $e');
    }
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  @override
  Future<List<UserAdminModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return getAllUsers();
      }

      final snapshot = await firestore.collection('users').get();

      final users = snapshot.docs
          .map((doc) => UserAdminModel.fromJson(doc.data()))
          .where(
            (u) =>
                u.name.toLowerCase().contains(query.toLowerCase()) ||
                u.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      AppLogger.d('Search "$query" returned ${users.length} users');
      return users;
    } catch (e) {
      throw AuthFirebaseException('User search failed: $e');
    }
  }
}
