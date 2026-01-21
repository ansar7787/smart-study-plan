import 'package:equatable/equatable.dart';
import '../../domain/entities/study_session.dart';

enum PlannerStatus { initial, loading, success, failure }

class PlannerState extends Equatable {
  final PlannerStatus status;
  final List<StudySession> sessions;
  final String? errorMessage;

  const PlannerState({
    this.status = PlannerStatus.initial,
    this.sessions = const [],
    this.errorMessage,
  });

  PlannerState copyWith({
    PlannerStatus? status,
    List<StudySession>? sessions,
    String? errorMessage,
  }) {
    return PlannerState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}
