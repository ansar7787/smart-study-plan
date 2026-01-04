import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import '../models/admin_stats_model.dart';
import '../models/user_admin_model.dart';
import '../../../../core/utils/logger.dart';

abstract class AdminRemoteDatasource {
  Future<List<UserAdminModel>> getAllUsers();
  Future<List<UserAdminModel>> getUsersByRole(String role);
  Future<void> deleteUser(String userId);
  Future<void> updateUserRole(String userId, String newRole);
  Future<AdminStatsModel> getAdminStats();
  Future<List<UserAdminModel>> searchUsers(String query);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final FirebaseFirestore _firestore;

  AdminRemoteDatasourceImpl(this._firestore);

  @override
  Future<List<UserAdminModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final users = snapshot.docs.map((doc) {
        return UserAdminModel.fromJson(doc.data());
      }).toList();

      AppLogger.d('Fetched ${users.length} users');
      return users;
    } catch (e) {
      throw AuthFirebaseException('Failed to get all users: $e');
    }
  }

  @override
  Future<List<UserAdminModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      final users = snapshot.docs.map((doc) {
        return UserAdminModel.fromJson(doc.data());
      }).toList();

      AppLogger.d('Fetched ${users.length} $role users');
      return users;
    } catch (e) {
      throw AuthFirebaseException('Failed to get users by role: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      AppLogger.d('User deleted: $userId');
    } catch (e) {
      throw AuthFirebaseException('Failed to delete user: $e');
    }
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      AppLogger.d('User role updated: $userId -> $newRole');
    } catch (e) {
      throw AuthFirebaseException('Failed to update user role: $e');
    }
  }

  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs;

      int students = 0;
      int admins = 0;

      for (var doc in users) {
        final role = doc.data()['role'] as String?;
        if (role == 'student') students++;
        if (role == 'admin') admins++;
      }

      final stats = AdminStatsModel(
        totalUsers: users.length,
        totalStudents: students,
        totalAdmins: admins,
        totalSubjects: 0, // Will update in Phase 3
        totalTasks: 0, // Will update in Phase 3
        lastUpdated: DateTime.now(),
      );

      AppLogger.d('Admin stats: ${stats.totalUsers} total users');
      return stats;
    } catch (e) {
      throw AuthFirebaseException('Failed to get admin stats: $e');
    }
  }

  @override
  Future<List<UserAdminModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return getAllUsers();
      }

      final snapshot = await _firestore.collection('users').get();

      final filteredUsers = snapshot.docs
          .where((doc) {
            final user = UserAdminModel.fromJson(doc.data());
            return user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase());
          })
          .map((doc) => UserAdminModel.fromJson(doc.data()))
          .toList();

      AppLogger.d('Search found ${filteredUsers.length} users for: $query');
      return filteredUsers;
    } catch (e) {
      throw AuthFirebaseException('Failed to search users: $e');
    }
  }
}
