import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_local_datasource.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
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
      // Try remote first
      final users = await remoteDatasource.getAllUsers();

      // Cache locally
      await localDatasource.cacheUsers(users);

      // Convert to entities
      return Right(users.map((u) => u.toEntity()).toList());
    } on AuthFirebaseException catch (e) {
      // Fallback to local cache
      try {
        final cachedUsers = await localDatasource.getCachedUsers();
        return Right(cachedUsers.map((u) => u.toEntity()).toList());
      } catch (_) {
        return Left(FirebaseAuthFailure(e.message, code: e.code));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get all users: $e'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByRole(String role) async {
    try {
      final users = await remoteDatasource.getUsersByRole(role);
      return Right(users.map((u) => u.toEntity()).toList());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get users by role: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDatasource.deleteUser(userId);

      // Update local cache
      final cachedUsers = await localDatasource.getCachedUsers();
      final updated = cachedUsers.where((user) => user.id != userId).toList();
      await localDatasource.cacheUsers(updated);

      return const Right(null);
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(
    String userId,
    String newRole,
  ) async {
    try {
      await remoteDatasource.updateUserRole(userId, newRole);
      return const Right(null);
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to update user role: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    try {
      final stats = await remoteDatasource.getAdminStats();

      // Cache locally
      await localDatasource.cacheAdminStats(stats);

      return Right(stats.toEntity());
    } on AuthFirebaseException catch (e) {
      // Fallback to local cache
      try {
        final cachedStats = await localDatasource.getCachedAdminStats();
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
      } catch (_) {}
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get admin stats: $e'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await remoteDatasource.searchUsers(query);
      return Right(users.map((u) => u.toEntity()).toList());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to search users: $e'));
    }
  }
}
