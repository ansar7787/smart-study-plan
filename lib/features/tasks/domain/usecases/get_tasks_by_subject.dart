import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksBySubjectUsecase extends UseCase<List<Task>, GetTasksParams> {
  final TaskRepository repository;

  GetTasksBySubjectUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Task>>> call(GetTasksParams params) async {
    return repository.getTasksBySubject(params.subjectId);
  }
}

class GetTasksParams {
  final String subjectId;
  const GetTasksParams({required this.subjectId});
}
