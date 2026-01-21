import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks_by_subject.dart';
import '../../domain/usecases/get_tasks_by_user.dart';

import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksBySubjectUsecase getTasksBySubjectUsecase;
  final GetTasksByUserUsecase getTasksByUserUsecase;
  final CreateTaskUsecase createTaskUsecase;
  final UpdateTaskUsecase updateTaskUsecase;
  final DeleteTaskUsecase deleteTaskUsecase;

  TaskBloc({
    required this.getTasksBySubjectUsecase,
    required this.getTasksByUserUsecase,
    required this.createTaskUsecase,
    required this.updateTaskUsecase,
    required this.deleteTaskUsecase,
  }) : super(const TaskState()) {
    on<LoadTasksBySubjectEvent>(_onLoadTasks);
    on<LoadTasksByUserEvent>(_onLoadTasksByUser);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(
    LoadTasksBySubjectEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    final result = await getTasksBySubjectUsecase(
      GetTasksParams(subjectId: event.subjectId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tasks) => emit(state.copyWith(status: TaskStatus.success, tasks: tasks)),
    );
  }

  Future<void> _onLoadTasksByUser(
    LoadTasksByUserEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    final result = await getTasksByUserUsecase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tasks) => emit(state.copyWith(status: TaskStatus.success, tasks: tasks)),
    );
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    final result = await createTaskUsecase(CreateTaskParams(task: event.task));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(
        LoadTasksBySubjectEvent(
          subjectId: event.task.subjectId,
          userId: event.task.userId,
        ),
      ),
    );
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    final result = await updateTaskUsecase(UpdateTaskParams(task: event.task));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(
        LoadTasksBySubjectEvent(
          subjectId: event.task.subjectId,
          userId: event.task.userId,
        ),
      ),
    );
  }

  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final updated = event.task.copyWith(isCompleted: !event.task.isCompleted);
    final currentTasks = List<Task>.from(state.tasks);

    // Optimistic Update
    final index = currentTasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      currentTasks[index] = updated;
      emit(state.copyWith(status: TaskStatus.success, tasks: currentTasks));
    }

    // Call API (silent update unless failure)
    final result = await updateTaskUsecase(UpdateTaskParams(task: updated));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {}, // Success, already updated
    );
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentTasks = List<Task>.from(state.tasks);

    // Optimistic Update
    currentTasks.removeWhere((t) => t.id == event.id);
    emit(state.copyWith(status: TaskStatus.success, tasks: currentTasks));

    final result = await deleteTaskUsecase(DeleteTaskParams(id: event.id));

    result.fold(
      (failure) => emit(
        state.copyWith(
          // Revert or show error
          status: TaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }
}
