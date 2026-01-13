import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_resource.dart';
import '../repositories/resource_repository.dart';

class ToggleFavoriteResourceUsecase extends UseCase<void, FileResource> {
  final ResourceRepository repository;

  ToggleFavoriteResourceUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(FileResource resource) {
    return repository.toggleFavorite(resource);
  }
}
