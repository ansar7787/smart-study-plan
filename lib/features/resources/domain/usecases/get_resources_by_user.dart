import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_resource.dart';
import '../repositories/resource_repository.dart';

class GetResourcesByUserUsecase extends UseCase<List<FileResource>, String> {
  final ResourceRepository repository;

  GetResourcesByUserUsecase({required this.repository});

  @override
  Future<Either<Failure, List<FileResource>>> call(String userId) {
    return repository.getResourcesByUser(userId);
  }
}
