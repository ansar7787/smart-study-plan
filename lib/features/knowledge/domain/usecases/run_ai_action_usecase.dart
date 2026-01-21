import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ai_repository.dart';
import '../entities/ai_action_result.dart';
import '../enums/ai_action_type.dart';

class RunAiActionUseCase {
  final AiRepository repository;

  RunAiActionUseCase(this.repository);

  Future<Either<Failure, AiActionResult>> call({
    required String userId,
    required AiActionType action,
    required String input,
  }) {
    return repository.runAction(userId: userId, action: action, input: input);
  }
}
