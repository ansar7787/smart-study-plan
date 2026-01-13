import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_local_datasource.dart';
import '../datasources/planner_remote_datasource.dart';
import '../models/study_session_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource remoteDataSource;
  final PlannerLocalDataSource localDataSource;
  final Connectivity connectivity;

  PlannerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<bool> _isOnline() async {
    final results = await connectivity.checkConnectivity();
    // online if at least one result is not 'none'
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, Unit>> createSession(StudySession session) async {
    try {
      final model = StudySessionModel.fromEntity(session);

      if (await _isOnline()) {
        await remoteDataSource.createSession(model);
      }

      await localDataSource.cacheSession(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSession(StudySession session) async {
    try {
      final model = StudySessionModel.fromEntity(session);

      if (await _isOnline()) {
        await remoteDataSource.updateSession(model);
      }

      await localDataSource.cacheSession(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSession(String sessionId) async {
    try {
      if (await _isOnline()) {
        await remoteDataSource.deleteSession(sessionId);
      }

      await localDataSource.deleteSession(sessionId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getSessionsByDate(
    DateTime date,
  ) async {
    try {
      if (await _isOnline()) {
        final remoteSessions = await remoteDataSource.getSessionsByDate(date);
        for (var session in remoteSessions) {
          await localDataSource.cacheSession(session);
        }
        return Right(remoteSessions.map((m) => m.toEntity()).toList());
      } else {
        final cachedSessions = await localDataSource.getSessionsByDate(date);
        return Right(cachedSessions.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      final cachedSessions = await localDataSource.getSessionsByDate(date);
      if (cachedSessions.isNotEmpty) {
        return Right(cachedSessions.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getSessionsByUser(
    String userId,
  ) async {
    try {
      if (await _isOnline()) {
        final remoteSessions = await remoteDataSource.getSessionsByUser(userId);
        for (var session in remoteSessions) {
          await localDataSource.cacheSession(session);
        }
        return Right(remoteSessions.map((m) => m.toEntity()).toList());
      } else {
        final cachedSessions = await localDataSource.getSessionsByUser(userId);
        return Right(cachedSessions.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      final cachedSessions = await localDataSource.getSessionsByUser(userId);
      if (cachedSessions.isNotEmpty) {
        return Right(cachedSessions.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
