import '../../domain/enums/ai_action_type.dart';

class AiPromptService {
  static String buildPrompt(AiActionType action, String input) {
    switch (action) {
      case AiActionType.summarize:
        return '''
Summarize the following text clearly and concisely:

$input
''';

      case AiActionType.explain:
        return '''
Rewrite the following text to improve clarity, grammar,
and understanding. Keep it simple and well-structured:

$input
''';

      case AiActionType.extractTasks:
        return '''
Extract actionable study tasks as a bullet list.
Each task should be short, specific, and clear.

Text:
$input
''';

      case AiActionType.brainstorm:
        return '''
Generate helpful ideas, insights, or extensions related to:

$input
''';
    }
  }
}
