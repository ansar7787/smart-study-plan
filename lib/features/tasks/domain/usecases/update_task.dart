import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUsecase extends UseCase<Task, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUsecase({required this.repository});

  @override
  Future<Either<Failure, Task>> call(UpdateTaskParams params) async {
    return repository.updateTask(params.task);
  }
}

class UpdateTaskParams {
  final Task task;
  const UpdateTaskParams({required this.task});
}
