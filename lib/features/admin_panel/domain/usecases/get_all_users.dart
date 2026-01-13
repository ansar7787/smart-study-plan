import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

import '../repositories/admin_repository.dart';

class GetAllUsersUseCase extends UseCase<List<User>, NoParams> {
  final AdminRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) {
    return repository.getAllUsers();
  }
}
