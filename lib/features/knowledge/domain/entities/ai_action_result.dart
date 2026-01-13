import 'package:equatable/equatable.dart';
import '../enums/ai_action_type.dart';
import 'extracted_task.dart';

class AiActionResult extends Equatable {
  final AiActionType action;
  final String output;

  // ✅ ONLY USED WHEN action == extractTasks
  final List<ExtractedTask> extractedTasks;

  const AiActionResult({
    required this.action,
    required this.output,
    this.extractedTasks = const [],
  });

  bool get hasTasks =>
      action == AiActionType.extractTasks && extractedTasks.isNotEmpty;

  @override
  List<Object?> get props => [action, output, extractedTasks];
}
