import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/failures.dart';

import '../entities/task.dart';

abstract class TaskRepository {
  // Create
  Future<Either<Failure, Task>> createTask(Task task);

  // Read
  Future<Either<Failure, Task>> getTask(String id);
  Future<Either<Failure, List<Task>>> getTasksBySubject(
    String subjectId,
    String userId,
  );
  Future<Either<Failure, List<Task>>> getTasksByUser(String userId);
  Future<Either<Failure, List<Task>>> getAllTasks();

  // Update
  Future<Either<Failure, Task>> updateTask(Task task);

  // Delete
  Future<Either<Failure, void>> deleteTask(String id);
}
