import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../repositories/subject_repository.dart';

class DeleteSubjectUsecase extends UseCase<void, DeleteSubjectParams> {
  final SubjectRepository repository;

  DeleteSubjectUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteSubjectParams params) async {
    return repository.deleteSubject(params.id);
  }
}

class DeleteSubjectParams {
  final String id;
  const DeleteSubjectParams({required this.id});
}
