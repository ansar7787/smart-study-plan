import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import 'package:smart_study_plan/core/error/failures.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_datasource.dart';
import '../datasources/subject_remote_datasource.dart';
import '../models/subject_model.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectRemoteDatasource remoteDatasource;
  final SubjectLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  SubjectRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Subject>> createSubject(Subject subject) async {
    try {
      if (await networkInfo.isConnected) {
        final model = SubjectModel.fromEntity(subject);
        final result = await remoteDatasource.createSubject(model);
        await localDatasource.cacheSubject(result);
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
  Future<Either<Failure, Subject>> getSubject(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getSubject(id);
        await localDatasource.cacheSubject(result);
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
  Future<Either<Failure, List<Subject>>> getSubjectsByUser(
    String userId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getSubjectsByUser(userId);
        await localDatasource.cacheSubjects(result);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        final cached = await localDatasource.getCachedSubjectsByUser(userId);
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
  Future<Either<Failure, List<Subject>>> getAllSubjects() async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDatasource.getAllSubjects();
        await localDatasource.cacheSubjects(result);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        final cached = await localDatasource.getAllCachedSubjects();
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
  Future<Either<Failure, Subject>> updateSubject(Subject subject) async {
    try {
      if (await networkInfo.isConnected) {
        final model = SubjectModel.fromEntity(subject);
        final result = await remoteDatasource.updateSubject(model);
        await localDatasource.cacheSubject(result);
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
  Future<Either<Failure, void>> deleteSubject(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDatasource.deleteSubject(id);
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
