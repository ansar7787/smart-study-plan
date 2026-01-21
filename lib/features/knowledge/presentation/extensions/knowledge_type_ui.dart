import 'package:flutter/material.dart';
import '../../domain/enums/knowledge_type.dart';

extension KnowledgeTypeUI on KnowledgeType {
  String get label {
    switch (this) {
      case KnowledgeType.note:
        return 'Note';
      case KnowledgeType.summary:
        return 'Summary';
      case KnowledgeType.idea:
        return 'Idea';
      case KnowledgeType.session:
        return 'Session';
    }
  }

  IconData get icon {
    switch (this) {
      case KnowledgeType.note:
        return Icons.note_alt_rounded;
      case KnowledgeType.summary:
        return Icons.summarize_rounded;
      case KnowledgeType.idea:
        return Icons.lightbulb_rounded;
      case KnowledgeType.session:
        return Icons.timer_outlined;
    }
  }

  Color get color {
    switch (this) {
      case KnowledgeType.note:
        return Colors.blue;
      case KnowledgeType.summary:
        return Colors.green;
      case KnowledgeType.idea:
        return Colors.orange;
      case KnowledgeType.session:
        return Colors.purple;
    }
  }
}
