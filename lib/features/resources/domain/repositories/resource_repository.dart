import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/file_resource.dart';

abstract class ResourceRepository {
  Future<Either<Failure, List<FileResource>>> getResourcesByUser(String userId);
  Future<Either<Failure, List<FileResource>>> getResourcesBySubject(
    String subjectId,
  );

  Future<Either<Failure, void>> uploadResource(
    FileResource resource, {
    required File file,
    void Function(double progress)? onProgress,
  });
  Future<Either<Failure, void>> toggleFavorite(FileResource resource);

  Future<Either<Failure, void>> softDelete(FileResource resource);
  Future<Either<Failure, void>> restore(FileResource resource);
}
