import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import '../../../../core/error/failures.dart';

abstract class AdminRepository {
  // User management
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> updateUserRole(String userId, UserRole newRole);

  // Stats
  Future<Either<Failure, AdminStats>> getAdminStats();

  // Search
  Future<Either<Failure, List<User>>> searchUsers(String query);
}
