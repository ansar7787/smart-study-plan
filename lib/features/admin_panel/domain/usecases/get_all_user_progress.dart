import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_progress.dart';
import '../repositories/admin_analytics_repository.dart';

class GetAllUserProgressUseCase extends UseCase<List<UserProgress>, NoParams> {
  final AdminAnalyticsRepository repository;

  GetAllUserProgressUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserProgress>>> call(NoParams params) {
    return repository.getAllUserProgress();
  }
}
