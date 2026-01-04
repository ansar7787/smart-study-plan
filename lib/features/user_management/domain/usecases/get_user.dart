import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class GetUserUseCase extends UseCase<User, String> {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(const ValidationFailure('User ID cannot be empty'));
    }

    return await repository.getUser(userId);
  }
}
