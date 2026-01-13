import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../datasources/ai_remote_datasource.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/entities/ai_action_result.dart';
import '../../domain/enums/ai_action_type.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remote;

  AiRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, AiActionResult>> runAction({
    required AiActionType action,
    required String input,
  }) {
    // ✅ Correct method name
    return remote.runAction(action: action, input: input);
  }
}
