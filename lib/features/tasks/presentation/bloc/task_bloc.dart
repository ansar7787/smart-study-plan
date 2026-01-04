import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/features/tasks/domain/entities/task.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/create_task.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/delete_task.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/get_tasks_by_subject.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksBySubjectUsecase getTasksBySubjectUsecase;
  final CreateTaskUsecase createTaskUsecase;
  final UpdateTaskUsecase updateTaskUsecase;
  final DeleteTaskUsecase deleteTaskUsecase;

  TaskBloc({
    required this.getTasksBySubjectUsecase,
    required this.createTaskUsecase,
    required this.updateTaskUsecase,
    required this.deleteTaskUsecase,
  }) : super(const TaskInitial()) {
    on<LoadTasksBySubjectEvent>(_onLoadTasksBySubject);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  // Load tasks by subject
  Future<void> _onLoadTasksBySubject(
    LoadTasksBySubjectEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await getTasksBySubjectUsecase(
      GetTasksParams(subjectId: event.subjectId),
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TaskListLoaded(tasks)),
    );
  }

  // Create task
  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await createTaskUsecase(CreateTaskParams(task: event.task));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskCreated(task)),
    );
  }

  // Update task
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await updateTaskUsecase(UpdateTaskParams(task: event.task));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskUpdated(task)),
    );
  }

  // Toggle task completion
  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
    );
    final result = await updateTaskUsecase(UpdateTaskParams(task: updatedTask));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskUpdated(task)),
    );
  }

  // Delete task
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final result = await deleteTaskUsecase(DeleteTaskParams(id: event.id));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => emit(TaskDeleted(event.id)),
    );
  }
}
