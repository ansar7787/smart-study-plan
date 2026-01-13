import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

class GetSessionsByDate {
  final PlannerRepository repository;
  GetSessionsByDate(this.repository);

  Future<Either<Failure, List<StudySession>>> call(DateTime date) {
    return repository.getSessionsByDate(date);
  }
}
