import 'package:flutter/material.dart';
import '../../domain/entities/ai_action_result.dart';

class AiResultView extends StatelessWidget {
  final AiActionResult result;

  const AiResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Result', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(result.output, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
