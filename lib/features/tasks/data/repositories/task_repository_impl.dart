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
  final TaskRemoteDatasource remoteDatasource;
  final TaskLocalDatasource localDatasource;
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
        final result = await remoteDatasource.createTask(model);
        await localDatasource.cacheTask(result);
        return Right(result.toEntity());
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
  Future<Either<Failure, Task>> getTask(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getTask(id);
        await localDatasource.cacheTask(result);
        return Right(result.toEntity());
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
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getTasksBySubject(subjectId);
        await localDatasource.cacheTasks(result);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        final cached = await localDatasource.getCachedTasksBySubject(subjectId);
        return Right(cached.map((model) => model.toEntity()).toList());
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
        final result = await remoteDatasource.getTasksByUser(userId);
        await localDatasource.cacheTasks(result);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        final cached = await localDatasource.getCachedTasksByUser(userId);
        return Right(cached.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getAllTasks();
        await localDatasource.cacheTasks(result);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        final cached = await localDatasource.getAllCachedTasks();
        return Right(cached.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      if (await networkInfo.isConnected) {
        final model = TaskModel.fromEntity(task);
        final result = await remoteDatasource.updateTask(model);
        await localDatasource.cacheTask(result);
        return Right(result.toEntity());
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
