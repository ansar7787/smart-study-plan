import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:smart_study_plan/config/ai/ai_config.dart';

import '../../../../core/error/failures.dart';
import '../../domain/enums/ai_action_type.dart';
import '../../domain/entities/ai_action_result.dart';

/// ===============================
/// AI REMOTE DATA SOURCE (ABSTRACT)
/// ===============================
abstract class AiRemoteDataSource {
  Future<Either<Failure, AiActionResult>> runAction({
    required AiActionType action,
    required String input,
  });
}

/// =======================================
/// AI REMOTE DATA SOURCE IMPLEMENTATION
/// =======================================
class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final http.Client client;

  AiRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, AiActionResult>> runAction({
    required AiActionType action,
    required String input,
  }) async {
    try {
      final apiKey = AiConfig.openAiKey;

      if (apiKey.isEmpty) {
        return const Left(ServerFailure('OpenAI API key not provided'));
      }

      final response = await client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': _systemPrompt(action)},
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure('AI request failed: ${response.body}'));
      }

      final data = jsonDecode(response.body);
      final output = data['choices'][0]['message']['content'] as String;

      return Right(AiActionResult(action: action, output: output));
    } catch (e) {
      return Left(ServerFailure('AI error: $e'));
    }
  }

  String _systemPrompt(AiActionType action) {
    switch (action) {
      case AiActionType.summarize:
        return 'Summarize the following content clearly and concisely.';
      case AiActionType.extractTasks:
        return 'Extract clear, actionable study tasks from the content.';
      case AiActionType.explain:
        return 'Explain the topic in simple, beginner-friendly terms.';
      case AiActionType.brainstorm:
        return 'Generate creative ideas and helpful insights.';
    }
  }
}
