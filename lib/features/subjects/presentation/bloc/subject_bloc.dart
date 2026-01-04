import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/features/subjects/domain/entities/subject.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/create_subject.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/delete_subject.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/get_subjects.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/update_subject.dart';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final GetSubjectsByUserUsecase getSubjectsByUserUsecase;
  final CreateSubjectUsecase createSubjectUsecase;
  final UpdateSubjectUsecase updateSubjectUsecase;
  final DeleteSubjectUsecase deleteSubjectUsecase;

  SubjectBloc({
    required this.getSubjectsByUserUsecase,
    required this.createSubjectUsecase,
    required this.updateSubjectUsecase,
    required this.deleteSubjectUsecase,
  }) : super(const SubjectInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  // Load all subjects for user
  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(const SubjectLoading());
    final result = await getSubjectsByUserUsecase(
      GetSubjectsParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(SubjectError(failure.message)),
      (subjects) => emit(SubjectListLoaded(subjects)),
    );
  }

  // Create subject
  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(const SubjectLoading());
    final result = await createSubjectUsecase(
      CreateSubjectParams(subject: event.subject),
    );
    result.fold(
      (failure) => emit(SubjectError(failure.message)),
      (subject) => emit(SubjectCreated(subject)),
    );
  }

  // Update subject
  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(const SubjectLoading());
    final result = await updateSubjectUsecase(
      UpdateSubjectParams(subject: event.subject),
    );
    result.fold(
      (failure) => emit(SubjectError(failure.message)),
      (subject) => emit(SubjectUpdated(subject)),
    );
  }

  // Delete subject
  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    final result = await deleteSubjectUsecase(
      DeleteSubjectParams(id: event.id),
    );
    result.fold(
      (failure) => emit(SubjectError(failure.message)),
      (_) => emit(SubjectDeleted(event.id)),
    );
  }
}
