import 'package:dartz/dartz.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class ResetPasswordUseCase extends UseCase<void, String> {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }
    return repository.resetPassword(email);
  }
}
