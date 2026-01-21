import '../../domain/entities/task.dart';
import 'package:smart_study_plan/core/bloc/base_event.dart';

abstract class TaskEvent extends BaseEvent {
  const TaskEvent();
}

class LoadTasksBySubjectEvent extends TaskEvent {
  final String subjectId;
  final String userId;
  const LoadTasksBySubjectEvent({
    required this.subjectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [subjectId, userId];
}

class LoadTasksByUserEvent extends TaskEvent {
  final String userId;
  const LoadTasksByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  const CreateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class ToggleTaskEvent extends TaskEvent {
  final Task task;
  const ToggleTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String id;
  final String subjectId;

  const DeleteTaskEvent({required this.id, required this.subjectId});

  @override
  List<Object?> get props => [id, subjectId];
}
