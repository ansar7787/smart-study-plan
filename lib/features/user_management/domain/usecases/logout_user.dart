import 'package:dartz/dartz.dart';
import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class LogoutUserUseCase extends UseCase<void, NoParams> {
  final UserRepository repository;

  LogoutUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logoutUser();
  }
}
