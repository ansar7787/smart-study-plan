import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class UpdateSubjectUsecase extends UseCase<Subject, UpdateSubjectParams> {
  final SubjectRepository repository;

  UpdateSubjectUsecase({required this.repository});

  @override
  Future<Either<Failure, Subject>> call(UpdateSubjectParams params) async {
    return repository.updateSubject(params.subject);
  }
}

class UpdateSubjectParams {
  final Subject subject;
  const UpdateSubjectParams({required this.subject});
}
