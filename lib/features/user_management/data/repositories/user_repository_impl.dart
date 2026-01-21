import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/firebase_error_handler.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource local;
  final UserRemoteDatasource remote;

  UserRepositoryImpl({required this.local, required this.remote});

  @override
  Future<Either<Failure, User>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final model = await remote.registerUser(
        email: email,
        password: password,
        name: name,
      );
      await local.saveUser(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownFailure(FirebaseErrorHandler.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser({
    required String email,
    required String password,
    String? googleIdToken,
  }) async {
    try {
      final model = await remote.loginUser(
        email: email,
        password: password,
        googleIdToken: googleIdToken,
      );
      await local.saveUser(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnknownFailure(FirebaseErrorHandler.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    await remote.logoutUser();
    await local.clearAllUsers();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remote.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(FirebaseErrorHandler.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    final model = await remote.getCurrentUser();
    if (model != null) {
      await local.saveUser(model);
      return Right(model.toEntity());
    }
    return const Right(null);
  }

  @override
  Future<bool> isUserLoggedIn() async => await remote.getCurrentUser() != null;

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final model = await remote.getUser(userId);
      await local.saveUser(model);
      return Right(model.toEntity());
    } catch (_) {
      final localUser = await local.getUser(userId);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }
      return const Left(CacheFailure('User not found'));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    final model = UserModel.fromEntity(user);
    await remote.updateUser(model);
    await local.saveUser(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    try {
      final url = await remote.uploadProfilePhoto(userId: userId, file: file);
      return Right(url);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    await remote.deleteUser(userId);
    await local.deleteUser(userId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> getUserRole(String userId) async {
    final user = await getUser(userId);
    return user.map((u) => u.role.value);
  }
}
