import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/core/error/failures.dart';
import 'package:smart_study_plan/features/knowledge/data/datasources/knowledge_ai_datasource.dart';
import 'package:smart_study_plan/features/knowledge/data/datasources/knowledge_local_datasource.dart';
import 'package:smart_study_plan/features/knowledge/data/models/knowledge_item_model.dart';
import 'package:smart_study_plan/features/knowledge/domain/entities/ai_action_result.dart';
import 'package:smart_study_plan/features/knowledge/domain/entities/knowledge_item.dart';
import 'package:smart_study_plan/features/knowledge/domain/enums/ai_action_type.dart';
import 'package:smart_study_plan/features/knowledge/domain/enums/knowledge_type.dart';
import 'package:smart_study_plan/features/knowledge/domain/repositories/knowledge_repository.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  final KnowledgeLocalDataSource local;
  final KnowledgeAiDataSource ai;

  KnowledgeRepositoryImpl({required this.local, required this.ai});

  @override
  Future<Either<Failure, List<KnowledgeItem>>> getItems(
    String userId, {
    KnowledgeType? type,
    String? subjectId,
  }) async {
    try {
      // 1️⃣ Get MODELS from local datasource
      final List<KnowledgeItemModel> models = await local.getAll(userId);

      // 2️⃣ Convert MODELS → ENTITIES
      final items = models.map((m) => m.toEntity()).toList();

      // 3️⃣ Apply filters on ENTITIES
      final filtered = items.where((item) {
        final typeMatch = type == null || item.type == type;
        final subjectMatch = subjectId == null || item.subjectId == subjectId;
        return typeMatch && subjectMatch;
      }).toList();

      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure('Failed to load knowledge items'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeItem>> createItem(KnowledgeItem item) async {
    try {
      await local.save(KnowledgeItemModel.fromEntity(item));
      return Right(item);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(KnowledgeItem item) async {
    try {
      await local.update(KnowledgeItemModel.fromEntity(item));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      await local.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiActionResult>> runAiAction({
    required AiActionType action,
    required String input,
  }) async {
    try {
      final output = await ai.run(action: action, input: input);
      return Right(AiActionResult(action: action, output: output));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
