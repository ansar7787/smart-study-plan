import 'package:smart_study_plan/core/bloc/base_event.dart';
import '../../domain/entities/subject.dart';

abstract class SubjectEvent extends BaseEvent {
  const SubjectEvent();
}

class LoadSubjectsEvent extends SubjectEvent {
  final String userId;
  const LoadSubjectsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateSubjectEvent extends SubjectEvent {
  final Subject subject;
  const CreateSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

class UpdateSubjectEvent extends SubjectEvent {
  final Subject subject;
  const UpdateSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

class DeleteSubjectEvent extends SubjectEvent {
  final String subjectId;
  const DeleteSubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}
