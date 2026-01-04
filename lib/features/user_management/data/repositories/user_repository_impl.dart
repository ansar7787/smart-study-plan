import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource localDatasource;
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, User>> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Register with Firebase
      final userModel = await remoteDatasource.registerUser(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      // Save to local storage
      await localDatasource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Try Firebase login
      final userModel = await remoteDatasource.loginUser(
        email: email,
        password: password,
      );

      // Save to local storage
      await localDatasource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    try {
      await remoteDatasource.logoutUser();
      await localDatasource.clearAllUsers();
      return const Right(null);
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final userModel = await remoteDatasource.getUser(userId);
      await localDatasource.saveUser(userModel);
      return Right(userModel.toEntity());
    } on AuthFirebaseException catch (e) {
      // Try fallback to local storage
      try {
        final localUser = await localDatasource.getUser(userId);
        if (localUser != null) {
          return Right(localUser.toEntity());
        }
      } catch (_) {}
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await remoteDatasource.updateUser(userModel);
      await localDatasource.saveUser(userModel);
      return const Right(null);
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await localDatasource.deleteUser(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete user: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDatasource.getCurrentUser();
      if (userModel != null) {
        await localDatasource.saveUser(userModel);
        return Right(userModel.toEntity());
      }
      return const Right(null);
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final user = await remoteDatasource.getCurrentUser();
      return user != null;
    } catch (e) {
      AppLogger.e('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<String?> getUserRole(String userId) async {
    try {
      final user = await getUser(userId);
      return user.fold((_) => null, (user) => user.role);
    } catch (e) {
      return null;
    }
  }
}
