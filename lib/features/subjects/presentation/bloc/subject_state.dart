import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';

enum SubjectStatus { initial, loading, success, failure }

class SubjectState extends Equatable {
  final SubjectStatus status;
  final List<Subject> subjects;
  final String? errorMessage;

  const SubjectState({
    this.status = SubjectStatus.initial,
    this.subjects = const [],
    this.errorMessage,
  });

  SubjectState copyWith({
    SubjectStatus? status,
    List<Subject>? subjects,
    String? errorMessage,
  }) {
    return SubjectState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage, // Reset error if not provided? Or keep?
      // Usually generic copyWith keeps it if null. But here if we change status to success, we usually want to clear error.
      // But let's stick to standard copyWith logic: "if argument provided, use it".
      // But wait, if I pass `status: success`, error might still linger if I don't set it null.
      // For this pattern, it's safer to allow explicit clearing or auto-clearing in Bloc.
      // I'll stick to standard null-coalescing here.
    );
  }

  @override
  List<Object?> get props => [status, subjects, errorMessage];
}
