import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/repositories/admin_repository.dart';

class GetAdminStatsUseCase extends UseCase<AdminStats, NoParams> {
  final AdminRepository repository;

  GetAdminStatsUseCase(this.repository);

  @override
  Future<Either<Failure, AdminStats>> call(NoParams params) async {
    return repository.getAdminStats();
  }
}
