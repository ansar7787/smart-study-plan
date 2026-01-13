import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_study_plan/core/bloc/base_bloc.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks_by_subject.dart';

import 'task_event.dart';

class TaskBloc extends BaseBloc<TaskEvent, List<Task>> {
  final GetTasksBySubjectUsecase getTasksBySubjectUsecase;
  final CreateTaskUsecase createTaskUsecase;
  final UpdateTaskUsecase updateTaskUsecase;
  final DeleteTaskUsecase deleteTaskUsecase;

  TaskBloc({
    required this.getTasksBySubjectUsecase,
    required this.createTaskUsecase,
    required this.updateTaskUsecase,
    required this.deleteTaskUsecase,
  }) : super(BaseState.initial()) {
    on<LoadTasksBySubjectEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  // ---------------- HELPERS ----------------

  List<Task> _currentTasks() {
    final viewState = state.viewState;
    if (viewState is ViewSuccess<List<Task>>) {
      return viewState.data;
    }
    return [];
  }

  // ---------------- LOAD ----------------

  Future<void> _onLoadTasks(
    LoadTasksBySubjectEvent event,
    Emitter<BaseState<List<Task>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getTasksBySubjectUsecase(
      GetTasksParams(subjectId: event.subjectId),
    );

    result.fold(
      (failure) => emitFailure(emit, failure),
      (tasks) => emitSuccess(emit, tasks),
    );
  }

  // ---------------- CREATE ----------------

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<BaseState<List<Task>>> emit,
  ) async {
    final result = await createTaskUsecase(CreateTaskParams(task: event.task));

    result.fold((failure) => emitFailure(emit, failure), (_) {
      add(LoadTasksBySubjectEvent(event.task.subjectId));
    });
  }

  // ---------------- UPDATE ----------------

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<BaseState<List<Task>>> emit,
  ) async {
    final result = await updateTaskUsecase(UpdateTaskParams(task: event.task));

    result.fold(
      (failure) => emitFailure(emit, failure),
      (_) => add(LoadTasksBySubjectEvent(event.task.subjectId)),
    );
  }

  // ---------------- TOGGLE (FIXED) ----------------

  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<BaseState<List<Task>>> emit,
  ) async {
    final updated = event.task.copyWith(isCompleted: !event.task.isCompleted);

    final tasks = _currentTasks();

    emitSuccess(
      emit,
      tasks.map((t) => t.id == updated.id ? updated : t).toList(),
    );

    await updateTaskUsecase(UpdateTaskParams(task: updated));
  }

  // ---------------- DELETE (FIXED) ----------------

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<BaseState<List<Task>>> emit,
  ) async {
    final tasks = _currentTasks();

    emitSuccess(emit, tasks.where((t) => t.id != event.id).toList());

    await deleteTaskUsecase(DeleteTaskParams(id: event.id));
  }
}
