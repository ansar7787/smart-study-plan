import 'package:equatable/equatable.dart';
import '../../domain/enums/knowledge_type.dart';
import '../../domain/enums/ai_action_type.dart';
import '../../domain/entities/knowledge_item.dart';

abstract class KnowledgeEvent extends Equatable {
  const KnowledgeEvent();

  @override
  List<Object?> get props => [];
}

// ---------------- LOAD ----------------

class LoadKnowledgeItemsEvent extends KnowledgeEvent {
  final String userId;
  final KnowledgeType? type;
  final String? subjectId; // ✅ ADD THIS
  final String? query; // [NEW] Search query

  const LoadKnowledgeItemsEvent({
    required this.userId,
    this.type,
    this.subjectId,
    this.query,
  });
}

// ---------------- CREATE ----------------

class CreateKnowledgeItemEvent extends KnowledgeEvent {
  final KnowledgeItem item;

  const CreateKnowledgeItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// ---------------- UPDATE ----------------

class UpdateKnowledgeItemEvent extends KnowledgeEvent {
  final KnowledgeItem item;

  const UpdateKnowledgeItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// ---------------- DELETE ----------------

class DeleteKnowledgeItemEvent extends KnowledgeEvent {
  final String id;

  const DeleteKnowledgeItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// ---------------- AI ----------------

class RunAiActionEvent extends KnowledgeEvent {
  final String userId;
  final AiActionType action;
  final String input;

  const RunAiActionEvent({
    required this.userId,
    required this.action,
    required this.input,
  });

  @override
  List<Object?> get props => [userId, action, input];
}
