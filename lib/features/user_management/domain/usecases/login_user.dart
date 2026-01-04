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
    // Validation
    if (params.email.isEmpty || params.password.isEmpty) {
      return const Left(ValidationFailure('Email and password required'));
    }

    if (!RegExp(AppConstants.emailPattern).hasMatch(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return repository.loginUser(email: params.email, password: params.password);
  }
}

class LoginUserParams extends Equatable {
  final String email;
  final String password;

  const LoginUserParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
