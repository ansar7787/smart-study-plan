import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/knowledge/domain/entities/knowledge_item.dart';
import 'package:smart_study_plan/features/knowledge/domain/enums/knowledge_type.dart';
import 'package:smart_study_plan/features/knowledge/domain/repositories/knowledge_repository.dart';

class GetKnowledgeItemsUseCase {
  final KnowledgeRepository repo;

  GetKnowledgeItemsUseCase(this.repo);

  Future<Either<Failure, List<KnowledgeItem>>> call(
    String userId, {
    KnowledgeType? type,
    String? subjectId, // ✅ ADD THIS
  }) {
    return repo.getItems(
      userId,
      type: type,
      subjectId: subjectId, // ✅ PASS THROUGH
    );
  }
}
