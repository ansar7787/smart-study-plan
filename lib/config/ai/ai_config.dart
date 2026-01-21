import 'api_keys.dart';

class AiConfig {
  static const openAiKey = String.fromEnvironment('OPENAI_API_KEY');
  // static const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const geminiKey = ApiKeys.geminiApiKey;
}
