import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_subject.dart';
import '../../domain/usecases/delete_subject.dart';
import '../../domain/usecases/get_subjects.dart';
import '../../domain/usecases/update_subject.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final GetSubjectsByUserUsecase getSubjectsByUser;
  final CreateSubjectUsecase createSubject;
  final UpdateSubjectUsecase updateSubject;
  final DeleteSubjectUsecase deleteSubject;

  SubjectBloc({
    required this.getSubjectsByUser,
    required this.createSubject,
    required this.updateSubject,
    required this.deleteSubject,
  }) : super(const SubjectState()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(state.copyWith(status: SubjectStatus.loading));

    final result = await getSubjectsByUser(
      GetSubjectsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubjectStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (subjects) => emit(
        state.copyWith(status: SubjectStatus.success, subjects: subjects),
      ),
    );
  }

  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(state.copyWith(status: SubjectStatus.loading));

    final result = await createSubject(
      CreateSubjectParams(subject: event.subject),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubjectStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadSubjectsEvent(event.subject.userId)),
    );
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(state.copyWith(status: SubjectStatus.loading));

    final result = await updateSubject(
      UpdateSubjectParams(subject: event.subject),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubjectStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadSubjectsEvent(event.subject.userId)),
    );
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(state.copyWith(status: SubjectStatus.loading));

    final result = await deleteSubject(
      DeleteSubjectParams(id: event.subjectId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubjectStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Optimistic update locally
        final updatedList = state.subjects
            .where((s) => s.id != event.subjectId)
            .toList();

        // If we want to stay in success state with new list
        emit(
          state.copyWith(status: SubjectStatus.success, subjects: updatedList),
        );
      },
    );
  }
}
