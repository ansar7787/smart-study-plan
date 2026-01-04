import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUsecase extends UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return repository.deleteTask(params.id);
  }
}

class DeleteTaskParams {
  final String id;
  const DeleteTaskParams({required this.id});
}
