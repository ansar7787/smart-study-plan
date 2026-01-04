import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../../core/error/failures.dart';

abstract class AdminRepository {
  // User Management
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, List<User>>> getUsersByRole(String role);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> updateUserRole(String userId, String newRole);

  // Statistics
  Future<Either<Failure, AdminStats>> getAdminStats();

  // Search & Filter
  Future<Either<Failure, List<User>>> searchUsers(String query);
}
