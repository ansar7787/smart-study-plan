import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analytics_repository.dart';

class DeleteStudyGoalUseCase implements UseCase<void, String> {
  final AnalyticsRepository repository;

  DeleteStudyGoalUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String goalId) {
    return repository.deleteGoal(goalId);
  }
}
