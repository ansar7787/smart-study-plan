import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUsecase extends UseCase<Task, CreateTaskParams> {
  final TaskRepository repository;

  CreateTaskUsecase({required this.repository});

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    return repository.createTask(params.task);
  }
}

class CreateTaskParams {
  final Task task;
  const CreateTaskParams({required this.task});
}
