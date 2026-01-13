import 'package:smart_study_plan/core/bloc/base_event.dart';
import '../../domain/entities/study_session.dart';

abstract class PlannerEvent extends BaseEvent {
  const PlannerEvent();
}

class LoadSessionsByUserEvent extends PlannerEvent {
  final String userId;
  const LoadSessionsByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadSessionsByDateEvent extends PlannerEvent {
  final DateTime date;
  const LoadSessionsByDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class CreateSessionEvent extends PlannerEvent {
  final StudySession session;
  const CreateSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

class UpdateSessionEvent extends PlannerEvent {
  final StudySession session;
  const UpdateSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

class DeleteSessionEvent extends PlannerEvent {
  final String sessionId;
  final String userId;

  const DeleteSessionEvent({required this.sessionId, required this.userId});

  @override
  List<Object?> get props => [sessionId, userId];
}
