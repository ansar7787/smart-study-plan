import 'package:flutter/material.dart';
import '../../domain/enums/ai_action_type.dart';

class InlineAiSuggestions extends StatelessWidget {
  final ValueChanged<AiActionType> onSelect;

  const InlineAiSuggestions({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _AiChip(
            icon: Icons.summarize,
            label: 'Summarize',
            color: colorScheme.primary,
            onTap: () => onSelect(AiActionType.summarize),
          ),
          _AiChip(
            icon: Icons.lightbulb_outline,
            label: 'Explain',
            color: colorScheme.secondary,
            onTap: () => onSelect(AiActionType.explain),
          ),
          _AiChip(
            icon: Icons.task_alt,
            label: 'Tasks',
            color: Colors.green,
            onTap: () => onSelect(AiActionType.extractTasks),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------

class _AiChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AiChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
