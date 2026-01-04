import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class CreateSubjectUsecase extends UseCase<Subject, CreateSubjectParams> {
  final SubjectRepository repository;

  CreateSubjectUsecase({required this.repository});

  @override
  @override
  Future<Either<Failure, Subject>> call(CreateSubjectParams params) async {
    // Create a new subject.
    return repository.createSubject(params.subject);
  }
}

class CreateSubjectParams {
  final Subject subject;
  const CreateSubjectParams({required this.subject});
}
