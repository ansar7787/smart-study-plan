import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/admin_panel/data/datasources/admin_local_datasource.dart';
import 'package:smart_study_plan/features/admin_panel/data/datasources/admin_remote_datasource.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/repositories/admin_repository.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import '../../../../core/error/failures.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;
  final AdminLocalDatasource localDatasource;

  AdminRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final users = await remoteDatasource.getAllUsers();
      await localDatasource.cacheUsers(users);
      return Right(users.map((u) => u.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to load users'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role) async {
    try {
      final users = await remoteDatasource.getUsersByRole(role.value);
      return Right(users.map((u) => u.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to load users by role'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDatasource.deleteUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to delete user'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(
    String userId,
    UserRole newRole,
  ) async {
    try {
      await remoteDatasource.updateUserRole(
        userId,
        newRole.value, // 🔁 ENUM → STRING
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to update role'));
    }
  }

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    try {
      final stats = await remoteDatasource.getAdminStats();
      await localDatasource.cacheAdminStats(stats);
      return Right(stats.toEntity());
    } catch (e) {
      return Left(UnknownFailure('Failed to load admin stats'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await remoteDatasource.searchUsers(query);
      return Right(users.map((u) => u.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Search failed'));
    }
  }
}
