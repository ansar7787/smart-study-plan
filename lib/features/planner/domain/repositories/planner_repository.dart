import '../entities/study_session.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class PlannerRepository {
  Future<Either<Failure, Unit>> createSession(StudySession session);
  Future<Either<Failure, Unit>> updateSession(StudySession session);
  Future<Either<Failure, Unit>> deleteSession(String sessionId);
  Future<Either<Failure, List<StudySession>>> getSessionsByDate(DateTime date);
  Future<Either<Failure, List<StudySession>>> getSessionsByUser(String userId);
}
