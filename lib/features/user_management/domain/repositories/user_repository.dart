import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/error/failures.dart';

abstract class UserRepository {
  // Authentication
  Future<Either<Failure, User>> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<Either<Failure, User>> loginUser({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logoutUser();

  // User Management
  Future<Either<Failure, User>> getUser(String userId);

  Future<Either<Failure, void>> updateUser(User user);

  Future<Either<Failure, void>> deleteUser(String userId);

  // Check Authentication
  Future<Either<Failure, User?>> getCurrentUser();

  Future<bool> isUserLoggedIn();

  Future<String?> getUserRole(String userId);
}
