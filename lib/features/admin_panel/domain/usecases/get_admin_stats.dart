import 'package:dartz/dartz.dart';
import '../entities/admin_stats.dart';
import '../repositories/admin_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

class GetAdminStatsUseCase extends UseCase<AdminStats, NoParams> {
  final AdminRepository repository;

  GetAdminStatsUseCase(this.repository);

  @override
  Future<Either<Failure, AdminStats>> call(NoParams params) {
    return repository.getAdminStats();
  }
}
