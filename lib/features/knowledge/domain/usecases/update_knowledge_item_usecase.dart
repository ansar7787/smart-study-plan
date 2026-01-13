import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/knowledge/domain/entities/knowledge_item.dart';
import 'package:smart_study_plan/features/knowledge/domain/repositories/knowledge_repository.dart';

class UpdateKnowledgeItemUseCase {
  final KnowledgeRepository repo;
  UpdateKnowledgeItemUseCase(this.repo);

  Future<Either<Failure, void>> call(KnowledgeItem item) {
    return repo.updateItem(item);
  }
}
