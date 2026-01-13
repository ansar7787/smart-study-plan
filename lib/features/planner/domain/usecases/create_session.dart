import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

class CreateSession {
  final PlannerRepository repository;
  CreateSession(this.repository);

  Future<Either<Failure, Unit>> call(StudySession session) {
    return repository.createSession(session);
  }
}
