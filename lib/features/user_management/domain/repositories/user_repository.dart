import 'dart:io';

import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/error/failures.dart';

abstract class UserRepository {
  // -----------------------------
  // AUTHENTICATION
  // -----------------------------

  /// Register user (role is ALWAYS student, enforced internally)
  Future<Either<Failure, User>> registerUser({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> loginUser({
    required String email,
    required String password,
    String? googleIdToken,
  });

  Future<Either<Failure, void>> logoutUser();

  Future<Either<Failure, void>> resetPassword(String email);

  // -----------------------------
  // AUTH STATE
  // -----------------------------

  Future<Either<Failure, User?>> getCurrentUser();

  Future<bool> isUserLoggedIn();

  // -----------------------------
  // USER MANAGEMENT
  // -----------------------------

  Future<Either<Failure, User>> getUser(String userId);

  /// Update profile (name / photo only)
  Future<Either<Failure, User>> updateUser(User user);

  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required File file,
  });

  /// Delete local + remote user data
  Future<Either<Failure, void>> deleteUser(String userId);

  /// Read-only role access
  Future<Either<Failure, String>> getUserRole(String userId);
}
