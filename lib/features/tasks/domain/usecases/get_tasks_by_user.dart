import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksByUserUsecase extends UseCase<List<Task>, String> {
  final TaskRepository repository;

  GetTasksByUserUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Task>>> call(String userId) async {
    return repository.getTasksByUser(userId);
  }
}
