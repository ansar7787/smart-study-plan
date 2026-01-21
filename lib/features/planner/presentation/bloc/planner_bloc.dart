import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/usecases/create_session.dart';
import '../../domain/usecases/update_session.dart';
import '../../domain/usecases/delete_session.dart';
import '../../domain/usecases/get_sessions_by_date.dart';
import '../../domain/usecases/get_sessions_by_user.dart';

import 'planner_event.dart';
import 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final CreateSession createSession;
  final UpdateSession updateSession;
  final DeleteSession deleteSession;
  final GetSessionsByDate getSessionsByDate;
  final GetSessionsByUser getSessionsByUser;

  PlannerBloc({
    required this.createSession,
    required this.updateSession,
    required this.deleteSession,
    required this.getSessionsByDate,
    required this.getSessionsByUser,
  }) : super(const PlannerState()) {
    on<LoadSessionsByUserEvent>(_onLoadByUser);
    on<LoadSessionsByDateEvent>(_onLoadByDate);
    on<CreateSessionEvent>(_onCreate);
    on<UpdateSessionEvent>(_onUpdate);
    on<DeleteSessionEvent>(_onDelete);
  }

  Future<void> _onLoadByUser(
    LoadSessionsByUserEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(status: PlannerStatus.loading));

    final result = await getSessionsByUser(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PlannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (sessions) => emit(
        state.copyWith(status: PlannerStatus.success, sessions: sessions),
      ),
    );
  }

  Future<void> _onLoadByDate(
    LoadSessionsByDateEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(status: PlannerStatus.loading));

    final result = await getSessionsByDate(event.date);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PlannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (sessions) => emit(
        state.copyWith(status: PlannerStatus.success, sessions: sessions),
      ),
    );
  }

  Future<void> _onCreate(
    CreateSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(status: PlannerStatus.loading));

    final result = await createSession(event.session);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PlannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadSessionsByUserEvent(event.session.userId)),
    );
  }

  Future<void> _onUpdate(
    UpdateSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(status: PlannerStatus.loading));

    final result = await updateSession(event.session);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PlannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadSessionsByUserEvent(event.session.userId)),
    );
  }

  Future<void> _onDelete(
    DeleteSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    // Optimistic Update
    final currentSessions = List<StudySession>.from(state.sessions);
    currentSessions.removeWhere((s) => s.id == event.sessionId);
    emit(
      state.copyWith(status: PlannerStatus.success, sessions: currentSessions),
    );

    final result = await deleteSession(event.sessionId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          // Revert/Error
          status: PlannerStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadSessionsByUserEvent(event.userId)), // Verify/Reload
    );
  }
}
