import 'package:equatable/equatable.dart';
import '../../domain/entities/knowledge_item.dart';
import '../../domain/entities/ai_action_result.dart'; // ✅ Import this

enum KnowledgeStatus { initial, loading, success, failure }

enum AiStatus { initial, loading, success, failure }

class KnowledgeState extends Equatable {
  final KnowledgeStatus status;
  final List<KnowledgeItem> items;
  final String? errorMessage;

  final AiStatus aiStatus;
  final AiActionResult? aiResult; // ✅ Changed from String? aiOutput

  const KnowledgeState({
    this.status = KnowledgeStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.aiStatus = AiStatus.initial,
    this.aiResult,
  });

  KnowledgeState copyWith({
    KnowledgeStatus? status,
    List<KnowledgeItem>? items,
    String? errorMessage,
    AiStatus? aiStatus,
    AiActionResult? aiResult,
  }) {
    return KnowledgeState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      aiStatus: aiStatus ?? this.aiStatus,
      aiResult: aiResult ?? this.aiResult,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, aiStatus, aiResult];
}
