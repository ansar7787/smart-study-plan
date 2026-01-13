import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/resources/domain/entities/file_resource.dart';
import 'package:smart_study_plan/features/resources/domain/repositories/resource_repository.dart';

class RestoreResourceUsecase {
  final ResourceRepository repository;
  RestoreResourceUsecase(this.repository);

  Future<Either<Failure, void>> call(FileResource resource) {
    return repository.restore(resource);
  }
}
