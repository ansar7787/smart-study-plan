import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class RegisterUserUseCase extends UseCase<User, RegisterUserParams> {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterUserParams params) async {
    if (params.email.isEmpty ||
        params.password.isEmpty ||
        params.name.isEmpty) {
      return const Left(ValidationFailure('All fields are required'));
    }

    return await repository.registerUser(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const RegisterUserParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}
