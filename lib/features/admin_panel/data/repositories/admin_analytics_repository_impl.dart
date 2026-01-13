import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/admin_analytics_repository.dart';
import '../datasources/admin_analytics_remote_ds.dart';

class AdminAnalyticsRepositoryImpl implements AdminAnalyticsRepository {
  final AdminAnalyticsRemoteDatasource remoteDatasource;

  AdminAnalyticsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<UserProgress>>> getAllUserProgress() async {
    try {
      final models = await remoteDatasource.getAllUserProgress();
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to load progress: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProgress>> getUserProgress(String userId) async {
    try {
      final model = await remoteDatasource.getUserProgress(userId);
      return Right(model.toEntity());
    } on AuthFirebaseException catch (e) {
      return Left(FirebaseAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to load user progress: $e'));
    }
  }
}
