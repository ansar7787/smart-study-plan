import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/study_goal.dart';
import '../repositories/analytics_repository.dart';
import '../enums/goal_metric_type.dart';
import '../enums/goal_status.dart';

class CreateStudyGoalUseCase implements UseCase<void, CreateStudyGoalParams> {
  final AnalyticsRepository repository;

  CreateStudyGoalUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateStudyGoalParams params) {
    final goal = StudyGoal(
      id: const Uuid().v4(),
      userId: params.userId,
      title: params.title,
      description: params.description,
      metricType: params.metricType,
      targetValue: params.targetValue,
      progress: 0,
      startDate: params.startDate,
      endDate: params.endDate,
      status: GoalStatus.active,
    );

    return repository.createGoal(goal);
  }
}

class CreateStudyGoalParams {
  final String userId;
  final String title;
  final String description;
  final GoalMetricType metricType;
  final double targetValue;
  final DateTime startDate;
  final DateTime endDate;

  const CreateStudyGoalParams({
    required this.userId,
    required this.title,
    required this.description,
    required this.metricType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
  });
}
