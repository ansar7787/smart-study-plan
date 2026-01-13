import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_progress.dart';
import '../repositories/admin_analytics_repository.dart';

class GetUserProgressUseCase extends UseCase<UserProgress, String> {
  final AdminAnalyticsRepository repository;

  GetUserProgressUseCase(this.repository);

  @override
  Future<Either<Failure, UserProgress>> call(String userId) {
    if (userId.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('UserId cannot be empty')),
      );
    }
    return repository.getUserProgress(userId);
  }
}
