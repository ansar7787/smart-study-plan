import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/file_resource.dart';
import '../repositories/resource_repository.dart';

class SoftDeleteResourceUsecase {
  final ResourceRepository repository;
  SoftDeleteResourceUsecase(this.repository);

  Future<Either<Failure, void>> call(FileResource resource) {
    return repository.softDelete(resource);
  }
}
