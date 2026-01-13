import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/core/bloc/base_bloc.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';

import '../../domain/entities/subject.dart';
import '../../domain/usecases/create_subject.dart';
import '../../domain/usecases/delete_subject.dart';
import '../../domain/usecases/get_subjects.dart';
import '../../domain/usecases/update_subject.dart';
import 'subject_event.dart';

class SubjectBloc extends BaseBloc<SubjectEvent, List<Subject>> {
  final GetSubjectsByUserUsecase getSubjectsByUser;
  final CreateSubjectUsecase createSubject;
  final UpdateSubjectUsecase updateSubject;
  final DeleteSubjectUsecase deleteSubject;

  SubjectBloc({
    required this.getSubjectsByUser,
    required this.createSubject,
    required this.updateSubject,
    required this.deleteSubject,
  }) : super(BaseState.initial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<BaseState<List<Subject>>> emit,
  ) async {
    emitLoading(emit);

    final result = await getSubjectsByUser(
      GetSubjectsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emitFailure(emit, failure),
      (subjects) => emitSuccess(emit, subjects),
    );
  }

  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<BaseState<List<Subject>>> emit,
  ) async {
    emitLoading(emit);

    final result = await createSubject(
      CreateSubjectParams(subject: event.subject),
    );

    result.fold(
      (failure) => emitFailure(emit, failure),
      (_) => add(LoadSubjectsEvent(event.subject.userId)),
    );
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<BaseState<List<Subject>>> emit,
  ) async {
    emitLoading(emit);

    final result = await updateSubject(
      UpdateSubjectParams(subject: event.subject),
    );

    result.fold(
      (failure) => emitFailure(emit, failure),
      (_) => add(LoadSubjectsEvent(event.subject.userId)),
    );
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<BaseState<List<Subject>>> emit,
  ) async {
    emitLoading(emit);

    final result = await deleteSubject(
      DeleteSubjectParams(id: event.subjectId),
    );

    result.fold((failure) => emitFailure(emit, failure), (_) {
      final current = state.viewState;
      if (current is ViewSuccess<List<Subject>>) {
        emitSuccess(
          emit,
          current.data.where((s) => s.id != event.subjectId).toList(),
        );
      }
    });
  }
}
