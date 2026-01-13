import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

class GetSessionsByUser {
  final PlannerRepository repository;
  GetSessionsByUser(this.repository);

  Future<Either<Failure, List<StudySession>>> call(String userId) {
    return repository.getSessionsByUser(userId);
  }
}
