import 'package:dartz/dartz.dart' hide Task;
import 'package:smart_study_plan/core/error/exceptions.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDatasource;
  final TaskLocalDataSource localDatasource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      if (await networkInfo.isConnected) {
        final model = TaskModel.fromEntity(task);
        await remoteDatasource.createTask(model);
        await localDatasource.cacheTask(model);
        return Right(model.toEntity());
      } else {
        // Offline: Save locally only
        final model = TaskModel.fromEntity(task);
        await localDatasource.cacheTask(model);
        // Note: We need a sync mechanism for these later.
        // For now, return success so user can proceed.
        return Right(model.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Task>> getTask(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final model = await remoteDatasource.getTask(id);
        await localDatasource.cacheTask(model);
        return Right(model.toEntity());
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksBySubject(
    String subjectId,
    String userId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getTasksBySubject(
          subjectId,
          userId,
        );
        // no bulk cache API; optionally cache individually
        for (final model in result) {
          await localDatasource.cacheTask(model);
        }
        return Right(result.map((m) => m.toEntity()).toList());
      } else {
        final cached = await localDatasource.getCachedTasksBySubject(subjectId);
        return Right(cached.map((m) => m.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByUser(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDatasource.getTasksByUser(userId);
          for (final model in result) {
            await localDatasource.cacheTask(model);
          }
        } catch (_) {
          // Sync failed, fallback to local
        }
      }

      // Always return local cache to ensure offline/unsynced tasks are visible
      final cached = await localDatasource.getAllCachedTasks();
      return Right(
        cached
            .where((t) => t.userId == userId)
            .map((m) => m.toEntity())
            .toList(),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDatasource.getAllTasks();
          for (final model in result) {
            await localDatasource.cacheTask(model);
          }
        } catch (_) {}
      }

      // Always return local cache
      final cached = await localDatasource.getAllCachedTasks();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      if (await networkInfo.isConnected) {
        final model = TaskModel.fromEntity(task);
        await remoteDatasource.updateTask(model);
        await localDatasource.cacheTask(model);
        return Right(model.toEntity());
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDatasource.deleteTask(id);
        await localDatasource.deleteCachedTask(id);
        return const Right(null);
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
