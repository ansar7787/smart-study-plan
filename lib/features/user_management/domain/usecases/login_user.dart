import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/constants/app_constants.dart';

class LoginUserUseCase extends UseCase<User, LoginUserParams> {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginUserParams params) async {
    // Validation: Require email/pass OR googleIdToken
    if (params.googleIdToken == null &&
        (params.email.isEmpty || params.password.isEmpty)) {
      return const Left(ValidationFailure('Email and password required'));
    }

    if (params.email.isNotEmpty &&
        !RegExp(AppConstants.emailPattern).hasMatch(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return repository.loginUser(
      email: params.email,
      password: params.password,
      googleIdToken: params.googleIdToken,
    );
  }
}

class LoginUserParams extends Equatable {
  final String email;
  final String password;
  final String? googleIdToken;

  const LoginUserParams({
    required this.email,
    required this.password,
    this.googleIdToken,
  });

  @override
  List<Object?> get props => [email, password, googleIdToken];
}
