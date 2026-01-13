import 'package:flutter/material.dart';
import 'package:smart_study_plan/features/knowledge/presentation/extensions/knowledge_type_ui.dart';
import '../../domain/enums/knowledge_type.dart';

class EmptyKnowledgeView extends StatelessWidget {
  final KnowledgeType type;

  const EmptyKnowledgeView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No ${type.label.toLowerCase()} yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to add your first one',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
