import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/study_goal.dart';
import '../repositories/analytics_repository.dart';

class UpdateStudyGoalUseCase implements UseCase<void, StudyGoal> {
  final AnalyticsRepository repository;

  UpdateStudyGoalUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(StudyGoal goal) {
    return repository.updateGoal(goal);
  }
}
