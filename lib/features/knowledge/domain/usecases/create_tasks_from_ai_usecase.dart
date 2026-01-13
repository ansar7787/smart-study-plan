import 'package:dartz/dartz.dart' hide Task;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../features/tasks/domain/entities/task.dart';
import '../../../../features/tasks/domain/repositories/task_repository.dart';
import '../entities/extracted_task.dart';

class CreateTasksFromAiUseCase {
  final TaskRepository taskRepository;

  CreateTasksFromAiUseCase(this.taskRepository);

  Future<Either<Failure, void>> call({
    required String userId,
    required List<ExtractedTask> tasks,
    String? subjectId, // optional override
  }) async {
    try {
      for (final t in tasks) {
        final now = DateTime.now();

        final task = Task(
          id: const Uuid().v4(),
          userId: userId,

          // ✅ REQUIRED FIELDS (FIXED)
          subjectId: subjectId ?? 'unassigned',
          title: t.title,
          description: t.description ?? '',
          tags: const [],
          priority: 2,
          status: 'todo',
          dueDate: now.add(const Duration(days: 1)),
          estimatedTime: null,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        );

        final result = await taskRepository.createTask(task);
        if (result.isLeft()) return result;
      }

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to create tasks from AI'));
    }
  }
}
