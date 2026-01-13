import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_resource.dart';
import '../repositories/resource_repository.dart';

typedef UploadProgress = void Function(double progress);

class UploadResourceUsecase extends UseCase<void, UploadResourceParams> {
  final ResourceRepository repository;

  UploadResourceUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadResourceParams params) {
    return repository.uploadResource(
      params.resource,
      file: params.file,
      onProgress: params.onProgress,
    );
  }
}

class UploadResourceParams {
  final FileResource resource;
  final File file;
  final UploadProgress? onProgress;

  const UploadResourceParams({
    required this.resource,
    required this.file,
    this.onProgress,
  });
}
