part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

// Load tasks by subject
class LoadTasksBySubjectEvent extends TaskEvent {
  final String subjectId;
  const LoadTasksBySubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

// Load tasks by user
class LoadTasksByUserEvent extends TaskEvent {
  final String userId;
  const LoadTasksByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Create task
class CreateTaskEvent extends TaskEvent {
  final Task task;
  const CreateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

// Update task
class UpdateTaskEvent extends TaskEvent {
  final Task task;
  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

// Toggle task completion
class ToggleTaskEvent extends TaskEvent {
  final Task task;
  const ToggleTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

// Delete task
class DeleteTaskEvent extends TaskEvent {
  final String id;
  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}
