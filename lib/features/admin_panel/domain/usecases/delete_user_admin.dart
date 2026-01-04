import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/admin_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class DeleteUserAdminUseCase extends UseCase<void, DeleteUserParams> {
  final AdminRepository repository;

  DeleteUserAdminUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteUserParams params) {
    return repository.deleteUser(params.userId);
  }
}

class DeleteUserParams extends Equatable {
  final String userId;

  const DeleteUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
