import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/analytics_overview.dart';
import '../repositories/analytics_repository.dart';

class LoadAnalyticsOverviewUseCase
    implements UseCase<AnalyticsOverview, LoadAnalyticsOverviewParams> {
  final AnalyticsRepository repository;

  LoadAnalyticsOverviewUseCase(this.repository);

  @override
  Future<Either<Failure, AnalyticsOverview>> call(
    LoadAnalyticsOverviewParams params,
  ) {
    return repository.loadOverview(
      userId: params.userId,
      start: params.start,
      end: params.end,
    );
  }
}

class LoadAnalyticsOverviewParams {
  final String userId;
  final DateTime? start;
  final DateTime? end;

  const LoadAnalyticsOverviewParams({
    required this.userId,
    this.start,
    this.end,
  });
}
