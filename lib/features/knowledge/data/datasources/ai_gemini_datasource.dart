import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/config/ai/ai_config.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ai_action_result.dart';
import '../../domain/entities/extracted_task.dart';
import '../../domain/enums/ai_action_type.dart';
import '../service/ai_prompt_service.dart';
import 'ai_remote_datasource.dart';

class AiGeminiDataSource implements AiRemoteDataSource {
  final http.Client client;
  // Use 'gemini-pro' or 'gemini-1.5-flash' depending on availability.
  // Using 'gemini-2.0-flash-exp' for speed/cost and availability.
  static const _model = 'gemini-2.0-flash-exp';

  AiGeminiDataSource({required this.client});

  @override
  Future<Either<Failure, AiActionResult>> runAction({
    required AiActionType action,
    required String input,
  }) async {
    try {
      final prompt = AiPromptService.buildPrompt(action, input);
      final apiKey = AiConfig.geminiKey; // Ensure you add this key to usage

      if (apiKey.isEmpty) {
        return Left(ServerFailure('Gemini API Key is missing'));
      }

      debugPrint('🤖 Sending Gemini request...');

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
      );

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      debugPrint('🤖 Gemini Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ Gemini Error: ${response.body}');
        return Left(ServerFailure('Gemini request failed: ${response.body}'));
      }

      final data = jsonDecode(response.body);
      final content =
          data['candidates'][0]['content']['parts'][0]['text'] as String;

      debugPrint('✅ Gemini Success: ${content.substring(0, 50)}...');

      // ✅ Extract tasks if required
      if (action == AiActionType.extractTasks) {
        final tasks = content
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            // Clean up markdown list items like "- ", "* ", "1. "
            .map((e) => e.replaceAll(RegExp(r'^[\-\*\d\.]+\s+'), '').trim())
            .where((e) => e.isNotEmpty)
            .map((e) => ExtractedTask(title: e))
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
    } catch (e, stack) {
      debugPrint('❌ Gemini Exception: $e');
      debugPrint(stack.toString());
      return Left(ServerFailure('Gemini error: $e'));
    }
  }
}
