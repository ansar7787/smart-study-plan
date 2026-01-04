import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../entities/subject.dart';

abstract class SubjectRepository {
  // Create
  Future<Either<Failure, Subject>> createSubject(Subject subject);

  // Read
  Future<Either<Failure, Subject>> getSubject(String id);
  Future<Either<Failure, List<Subject>>> getSubjectsByUser(String userId);
  Future<Either<Failure, List<Subject>>> getAllSubjects();

  // Update
  Future<Either<Failure, Subject>> updateSubject(Subject subject);

  // Delete
  Future<Either<Failure, void>> deleteSubject(String id);
}
