part of 'subject_bloc.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

// Initial state
class SubjectInitial extends SubjectState {
  const SubjectInitial();
}

// Loading state
class SubjectLoading extends SubjectState {
  const SubjectLoading();
}

// List loaded successfully
class SubjectListLoaded extends SubjectState {
  final List<Subject> subjects;
  const SubjectListLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

// Single subject loaded
class SubjectLoaded extends SubjectState {
  final Subject subject;
  const SubjectLoaded(this.subject);

  @override
  List<Object?> get props => [subject];
}

// Created successfully
class SubjectCreated extends SubjectState {
  final Subject subject;
  const SubjectCreated(this.subject);

  @override
  List<Object?> get props => [subject];
}

// Updated successfully
class SubjectUpdated extends SubjectState {
  final Subject subject;
  const SubjectUpdated(this.subject);

  @override
  List<Object?> get props => [subject];
}

// Deleted successfully
class SubjectDeleted extends SubjectState {
  final String id;
  const SubjectDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

// Error state
class SubjectError extends SubjectState {
  final String message;
  const SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
