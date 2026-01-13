import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../repositories/planner_repository.dart';

class DeleteSession {
  final PlannerRepository repository;
  DeleteSession(this.repository);

  Future<Either<Failure, Unit>> call(String sessionId) {
    return repository.deleteSession(sessionId);
  }
}
