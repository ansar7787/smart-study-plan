import 'package:smart_study_plan/features/knowledge/domain/enums/knowledge_type.dart';

class KnowledgeItem {
  final String id;
  final String userId;
  final String title;
  final String content;
  final KnowledgeType type;
  final String? subjectId; // ✅ NEW
  final bool isPinned; // ✅ NEW
  final DateTime createdAt;

  KnowledgeItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.subjectId,
    this.isPinned = false,
    required this.createdAt,
  });

  KnowledgeItem copyWith({
    String? title,
    String? content,
    KnowledgeType? type,
    String? subjectId,
    bool? isPinned,
  }) {
    return KnowledgeItem(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
    );
  }
}
