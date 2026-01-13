import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

class UpdateSession {
  final PlannerRepository repository;
  UpdateSession(this.repository);

  Future<Either<Failure, Unit>> call(StudySession session) {
    return repository.updateSession(session);
  }
}
