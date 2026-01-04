import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class GetSubjectsByUserUsecase
    extends UseCase<List<Subject>, GetSubjectsParams> {
  final SubjectRepository repository;

  GetSubjectsByUserUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Subject>>> call(GetSubjectsParams params) async {
    return repository.getSubjectsByUser(params.userId);
  }
}

class GetSubjectsParams {
  final String userId;
  const GetSubjectsParams({required this.userId});
}
