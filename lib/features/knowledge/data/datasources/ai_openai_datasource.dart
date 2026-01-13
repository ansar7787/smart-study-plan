import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/config/ai/ai_config.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ai_action_result.dart';
import '../../domain/entities/extracted_task.dart';
import '../../domain/enums/ai_action_type.dart';
import '../service/ai_prompt_service.dart';
import 'ai_remote_datasource.dart';

class AiOpenAiDataSource implements AiRemoteDataSource {
  final http.Client client;

  AiOpenAiDataSource({required this.client});

  @override
  Future<Either<Failure, AiActionResult>> runAction({
    required AiActionType action,
    required String input,
  }) async {
    try {
      final prompt = AiPromptService.buildPrompt(action, input);

      final response = await client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AiConfig.openAiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure('AI request failed: ${response.body}'));
      }

      final content =
          jsonDecode(response.body)['choices'][0]['message']['content']
              as String;

      // ✅ Extract tasks if required
      if (action == AiActionType.extractTasks) {
        final tasks = content
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .map((e) => ExtractedTask(title: e.replaceAll('-', '').trim()))
            .toList();

        return Right(
          AiActionResult(
            action: action,
            output: content,
            extractedTasks: tasks,
          ),
        );
      }

      return Right(AiActionResult(action: action, output: content));
    } catch (e) {
      return Left(ServerFailure('AI error: $e'));
    }
  }
}
