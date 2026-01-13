import 'package:equatable/equatable.dart';
import '../../domain/entities/knowledge_item.dart';
import '../../domain/entities/ai_action_result.dart';

abstract class KnowledgeState extends Equatable {
  const KnowledgeState();

  @override
  List<Object?> get props => [];
}

class KnowledgeInitial extends KnowledgeState {}

class KnowledgeLoading extends KnowledgeState {}

class KnowledgeLoaded extends KnowledgeState {
  final List<KnowledgeItem> items;

  const KnowledgeLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class KnowledgeError extends KnowledgeState {
  final String message;

  const KnowledgeError(this.message);

  @override
  List<Object?> get props => [message];
}

// -------- CRUD FEEDBACK --------

class KnowledgeItemCreated extends KnowledgeState {
  final KnowledgeItem item;

  const KnowledgeItemCreated(this.item);

  @override
  List<Object?> get props => [item];
}

class KnowledgeItemUpdated extends KnowledgeState {}

class KnowledgeItemDeleted extends KnowledgeState {}

// -------- AI --------

class AiActionRunning extends KnowledgeState {}

class AiActionCompleted extends KnowledgeState {
  final AiActionResult result;

  const AiActionCompleted(this.result);

  @override
  List<Object?> get props => [result];
}
