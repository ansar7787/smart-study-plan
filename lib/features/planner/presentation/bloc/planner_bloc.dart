import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_study_plan/core/bloc/base_bloc.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/usecases/create_session.dart';
import '../../domain/usecases/update_session.dart';
import '../../domain/usecases/delete_session.dart';
import '../../domain/usecases/get_sessions_by_date.dart';
import '../../domain/usecases/get_sessions_by_user.dart';

import 'planner_event.dart';

class PlannerBloc extends BaseBloc<PlannerEvent, List<StudySession>> {
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
  }) : super(BaseState.initial()) {
    on<LoadSessionsByUserEvent>(_onLoadByUser);
    on<LoadSessionsByDateEvent>(_onLoadByDate);
    on<CreateSessionEvent>(_onCreate);
    on<UpdateSessionEvent>(_onUpdate);
    on<DeleteSessionEvent>(_onDelete);
  }

  // ---------------- LOAD BY USER ----------------

  Future<void> _onLoadByUser(
    LoadSessionsByUserEvent event,
    Emitter<BaseState<List<StudySession>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getSessionsByUser(event.userId);

    result.fold(
      (failure) => emitFailure(emit, failure),
      (sessions) => emitSuccess(emit, sessions),
    );
  }

  // ---------------- LOAD BY DATE ----------------

  Future<void> _onLoadByDate(
    LoadSessionsByDateEvent event,
    Emitter<BaseState<List<StudySession>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getSessionsByDate(event.date);

    result.fold(
      (failure) => emitFailure(emit, failure),
      (sessions) => emitSuccess(emit, sessions),
    );
  }

  // ---------------- CREATE ----------------

  Future<void> _onCreate(
    CreateSessionEvent event,
    Emitter<BaseState<List<StudySession>>> emit,
  ) async {
    final result = await createSession(event.session);

    result.fold((failure) => emitFailure(emit, failure), (_) {
      // ✅ ONLY reload data
      add(LoadSessionsByUserEvent(event.session.userId));
    });
  }

  // ---------------- UPDATE ----------------

  Future<void> _onUpdate(
    UpdateSessionEvent event,
    Emitter<BaseState<List<StudySession>>> emit,
  ) async {
    final result = await updateSession(event.session);

    result.fold((failure) => emitFailure(emit, failure), (_) {
      add(LoadSessionsByUserEvent(event.session.userId));
    });
  }

  // ---------------- DELETE ----------------

  Future<void> _onDelete(
    DeleteSessionEvent event,
    Emitter<BaseState<List<StudySession>>> emit,
  ) async {
    final result = await deleteSession(event.sessionId);

    result.fold(
      (failure) => emitFailure(emit, failure),
      (_) => add(LoadSessionsByUserEvent(event.userId)),
    );
  }
}
