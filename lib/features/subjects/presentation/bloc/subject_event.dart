part of 'subject_bloc.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

// Load all subjects for a user
class LoadSubjectsEvent extends SubjectEvent {
  final String userId;
  const LoadSubjectsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Create new subject
class CreateSubjectEvent extends SubjectEvent {
  final Subject subject;
  const CreateSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

// Update existing subject
class UpdateSubjectEvent extends SubjectEvent {
  final Subject subject;
  const UpdateSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

// Delete subject
class DeleteSubjectEvent extends SubjectEvent {
  final String id;
  const DeleteSubjectEvent(this.id);

  @override
  List<Object?> get props => [id];
}
