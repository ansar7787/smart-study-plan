import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/knowledge/domain/repositories/knowledge_repository.dart';

class DeleteKnowledgeItemUseCase {
  final KnowledgeRepository repo;
  DeleteKnowledgeItemUseCase(this.repo);

  Future<Either<Failure, void>> call(String id) {
    return repo.deleteItem(id);
  }
}
