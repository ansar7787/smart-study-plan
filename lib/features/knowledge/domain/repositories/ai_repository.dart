import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ai_action_result.dart';
import '../enums/ai_action_type.dart';

abstract class AiRepository {
  Future<Either<Failure, AiActionResult>> runAction({
    required String userId,
    required AiActionType action,
    required String input,
  });
}
