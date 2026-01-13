import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_progress.dart';

abstract class AdminAnalyticsRepository {
  /// All users progress (admin overview)
  Future<Either<Failure, List<UserProgress>>> getAllUserProgress();

  /// Single user detailed progress
  Future<Either<Failure, UserProgress>> getUserProgress(String userId);
}
