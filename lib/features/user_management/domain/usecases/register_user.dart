import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/constants/app_constants.dart';

class RegisterUserUseCase extends UseCase<User, RegisterUserParams> {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterUserParams params) async {
    // Validation
    final validation = _validateInputs(
      email: params.email,
      password: params.password,
      name: params.name,
    );

    if (validation != null) {
      return Left(validation);
    }

    return repository.registerUser(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );
  }

  Failure? _validateInputs({
    required String email,
    required String password,
    required String name,
  }) {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return const ValidationFailure('All fields are required');
    }

    if (!RegExp(AppConstants.emailPattern).hasMatch(email)) {
      return const ValidationFailure('Invalid email format');
    }

    if (password.length < AppConstants.minPasswordLength) {
      return ValidationFailure(
        'Password must be at least ${AppConstants.minPasswordLength} characters',
      );
    }

    if (name.length < AppConstants.minNameLength) {
      return ValidationFailure(
        'Name must be at least ${AppConstants.minNameLength} characters',
      );
    }

    return null;
  }
}

class RegisterUserParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterUserParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}
