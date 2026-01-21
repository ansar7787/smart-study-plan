import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/resources/data/datasources/resource_storage_datasource.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/file_resource.dart';
import '../../domain/repositories/resource_repository.dart';
import '../datasources/resource_local_datasource.dart';
import '../datasources/resource_remote_datasource.dart';
import '../models/file_resource_model.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceRemoteDataSource remote;
  final ResourceLocalDataSource local;
  final ResourceStorageDataSource storage;

  ResourceRepositoryImpl({
    required this.remote,
    required this.local,
    required this.storage,
  });

  @override
  Future<Either<Failure, List<FileResource>>> getResourcesByUser(
    String userId,
  ) async {
    try {
      final remoteModels = await remote.getResourcesByUser(userId);

      for (final model in remoteModels) {
        await local.cacheResource(model);
      }

      return Right(remoteModels.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = await local.getResourcesByUser(userId);
      return cached.isNotEmpty
          ? Right(cached.map((e) => e.toEntity()).toList())
          : Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FileResource>>> getResourcesBySubject(
    String subjectId,
  ) async {
    try {
      final remoteModels = await remote.getResourcesBySubject(subjectId);

      for (final model in remoteModels) {
        await local.cacheResource(model);
      }

      return Right(remoteModels.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = await local.getResourcesBySubject(subjectId);
      return cached.isNotEmpty
          ? Right(cached.map((e) => e.toEntity()).toList())
          : Left(ServerFailure(e.toString()));
    }
  }

  /// ✅ REAL UPLOAD IMPLEMENTATION
  @override
  Future<Either<Failure, void>> uploadResource(
    FileResource resource, {
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // 🛑 LIMIT: 10MB (Per File)
      final sizeInBytes = await file.length();
      if (sizeInBytes > 10 * 1024 * 1024) {
        return Left(ServerFailure('File too large (Max 10MB)'));
      }

      // 🛑 LIMIT: 250MB (Total Storage)
      final remoteModels = await remote.getResourcesByUser(resource.userId);
      final currentTotalSize = remoteModels.fold<int>(
        0,
        (sum, item) => sum + item.size,
      );

      if (currentTotalSize + sizeInBytes > 250 * 1024 * 1024) {
        return Left(
          ServerFailure(
            'Maximum storage used (250MB already utilized). Please delete some resources to free up space.',
          ),
        );
      }

      final uploadTask = storage.uploadFile(
        file: file,
        userId: resource.userId,
        fileName: resource.id,
      );

      uploadTask.snapshotEvents.listen((snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      final model = FileResourceModel.fromEntity(resource).copyWith(url: url);

      await remote.uploadResource(model);
      await local.cacheResource(model);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(FileResource resource) async {
    try {
      final updated = resource.copyWith(isFavorite: !resource.isFavorite);
      final model = FileResourceModel.fromEntity(updated);

      await remote.uploadResource(model);
      await local.cacheResource(model);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> softDelete(FileResource resource) async {
    try {
      final updated = resource.copyWith(isDeleted: true);
      final model = FileResourceModel.fromEntity(updated);

      await remote.uploadResource(model);
      await local.cacheResource(model);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restore(FileResource resource) async {
    try {
      final updated = resource.copyWith(isDeleted: false);
      final model = FileResourceModel.fromEntity(updated);

      await remote.uploadResource(model);
      await local.cacheResource(model);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
