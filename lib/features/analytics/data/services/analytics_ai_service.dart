import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../knowledge/domain/repositories/ai_repository.dart';
import '../../../knowledge/domain/enums/ai_action_type.dart';

class AnalyticsAiService {
  final AiRepository aiRepository;

  AnalyticsAiService(this.aiRepository);

  Future<Either<Failure, String>> generateInsight(
    String userId,
    String analyticsSummary,
  ) async {
    final result = await aiRepository.runAction(
      userId: userId,
      action: AiActionType.summarize,
      input:
          'Generate a motivational insight from this analytics:\n$analyticsSummary',
    );

    // ✅ Now we are mapping on Either, not Future
    return result.map((r) => r.output);
  }
}
