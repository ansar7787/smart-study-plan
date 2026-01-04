part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

// List loaded successfully
class TaskListLoaded extends TaskState {
  final List<Task> tasks;
  const TaskListLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

// Created successfully
class TaskCreated extends TaskState {
  final Task task;
  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

// Updated successfully
class TaskUpdated extends TaskState {
  final Task task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

// Deleted successfully
class TaskDeleted extends TaskState {
  final String id;
  const TaskDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

// Error state
class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
