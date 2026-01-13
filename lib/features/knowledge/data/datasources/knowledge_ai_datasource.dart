import 'package:smart_study_plan/features/knowledge/domain/enums/ai_action_type.dart';

abstract class KnowledgeAiDataSource {
  Future<String> run({required AiActionType action, required String input});
}

class KnowledgeAiDataSourceImpl implements KnowledgeAiDataSource {
  @override
  Future<String> run({
    required AiActionType action,
    required String input,
  }) async {
    // Mock delay (offline / demo mode)
    await Future.delayed(const Duration(seconds: 1));

    switch (action) {
      case AiActionType.summarize:
        return 'Summary: ${_safeSnippet(input)}';

      case AiActionType.explain:
        return 'Improved & clarified version:\n$input';

      case AiActionType.extractTasks:
        return '- Task 1\n- Task 2\n- Task 3';

      case AiActionType.brainstorm:
        return 'Ideas:\n• Idea 1\n• Idea 2\n• Idea 3';
    }
  }

  String _safeSnippet(String input) {
    if (input.length <= 50) return input;
    return '${input.substring(0, 50)}...';
  }
}
