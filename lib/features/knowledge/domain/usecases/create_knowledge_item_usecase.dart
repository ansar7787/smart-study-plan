import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/knowledge/domain/entities/knowledge_item.dart';
import 'package:smart_study_plan/features/knowledge/domain/repositories/knowledge_repository.dart';

class CreateKnowledgeItemUseCase {
  final KnowledgeRepository repo;
  CreateKnowledgeItemUseCase(this.repo);

  Future<Either<Failure, KnowledgeItem>> call(KnowledgeItem item) {
    return repo.createItem(item);
  }
}
