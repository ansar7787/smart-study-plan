import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/study_goal.dart';
import '../repositories/analytics_repository.dart';

class GetActiveGoalsUseCase implements UseCase<List<StudyGoal>, String> {
  final AnalyticsRepository repository;

  GetActiveGoalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StudyGoal>>> call(String userId) {
    return repository.getActiveGoals(userId);
  }
}
