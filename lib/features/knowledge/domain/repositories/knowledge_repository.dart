import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/knowledge_item.dart';
import '../entities/ai_action_result.dart';
import '../enums/knowledge_type.dart';
import '../enums/ai_action_type.dart';

abstract class KnowledgeRepository {
  Future<Either<Failure, List<KnowledgeItem>>> getItems(
    String userId, {
    KnowledgeType? type,
    String? subjectId, // ✅ ADD THIS
  });

  Future<Either<Failure, KnowledgeItem>> createItem(KnowledgeItem item);
  Future<Either<Failure, void>> updateItem(KnowledgeItem item);
  Future<Either<Failure, void>> deleteItem(String id);

  // 🤖 AI
  Future<Either<Failure, AiActionResult>> runAiAction({
    required AiActionType action,
    required String input,
  });
}
