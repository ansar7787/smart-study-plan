import 'package:hive/hive.dart';

import '../../domain/entities/knowledge_item.dart';
import '../../domain/enums/knowledge_type.dart';

part 'knowledge_item_model.g.dart';

@HiveType(typeId: 12)
class KnowledgeItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final KnowledgeType type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? subjectId;

  @HiveField(7)
  final bool isPinned;

  KnowledgeItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    this.subjectId,
    this.isPinned = false,
  });

  // ================= MAPPERS =================

  /// Model → Domain Entity
  KnowledgeItem toEntity() {
    return KnowledgeItem(
      id: id,
      userId: userId,
      type: type,
      title: title,
      content: content,
      createdAt: createdAt,
      subjectId: subjectId,
      isPinned: isPinned,
    );
  }

  /// Domain Entity → Model
  factory KnowledgeItemModel.fromEntity(KnowledgeItem e) {
    return KnowledgeItemModel(
      id: e.id,
      userId: e.userId,
      type: e.type,
      title: e.title,
      content: e.content,
      createdAt: e.createdAt,
      subjectId: e.subjectId,
      isPinned: e.isPinned,
    );
  }
}
