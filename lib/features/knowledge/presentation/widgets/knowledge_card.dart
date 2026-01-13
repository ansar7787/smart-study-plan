import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/knowledge/presentation/widgets/knowledge_editor_page.dart';

import '../../domain/entities/knowledge_item.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../extensions/knowledge_type_ui.dart';
import '../widgets/ai_action_bottom_sheet.dart';
import '../widgets/inline_ai_suggestions.dart';

/// ---------------------------------------------------------------------------
/// 🧠 KNOWLEDGE CARD (LIST ITEM)
/// ---------------------------------------------------------------------------
/// - Swipe → delete (with undo)
/// - Tap → edit note
/// - Pin / AI actions
/// - Colorful type indicator (Note / Summary / Idea)
/// ---------------------------------------------------------------------------
class KnowledgeCard extends StatelessWidget {
  final KnowledgeItem item;

  const KnowledgeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,

      // 🔴 DELETE BACKGROUND
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      // ❗ CONFIRM BEFORE DELETE
      confirmDismiss: (_) => _confirmDelete(context),

      // ✅ DELETE ACTION
      onDismissed: (_) {
        final bloc = context.read<KnowledgeBloc>();

        bloc.add(DeleteKnowledgeItemEvent(item.id));

        // 🔁 UNDO SUPPORT
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                bloc.add(CreateKnowledgeItemEvent(item));
              },
            ),
          ),
        );
      },

      child: _CardBody(item: item),
    );
  }

  /// -------------------------------------------------------------------------
  /// ❗ DELETE CONFIRMATION DIALOG
  /// -------------------------------------------------------------------------
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete note?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// ---------------------------------------------------------------------------
/// 🧱 CARD BODY
/// ---------------------------------------------------------------------------
class _CardBody extends StatelessWidget {
  final KnowledgeItem item;

  const _CardBody({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      // ✏️ TAP → EDIT PAGE
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KnowledgeEditorPage(item: item)),
        );
      },

      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: item.type.color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // 🏷️ TYPE ROW (ICON + LABEL)
              // ----------------------------------------------------------------
              Row(
                children: [
                  Icon(item.type.icon, size: 16, color: item.type.color),
                  const SizedBox(width: 6),
                  Text(
                    item.type.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: item.type.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),

                  // 📌 PIN ACTION
                  IconButton(
                    tooltip: 'Pin',
                    icon: Icon(
                      item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: item.isPinned
                          ? Colors.orange
                          : theme.iconTheme.color,
                    ),
                    onPressed: () {
                      context.read<KnowledgeBloc>().add(
                        UpdateKnowledgeItemEvent(
                          item.copyWith(isPinned: !item.isPinned),
                        ),
                      );
                    },
                  ),

                  // 🤖 AI ACTION
                  IconButton(
                    tooltip: 'AI Assistant',
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: () => _openAi(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ----------------------------------------------------------------
              // 📌 TITLE
              // ----------------------------------------------------------------
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------------------
              // 📝 CONTENT PREVIEW
              // ----------------------------------------------------------------
              Text(
                item.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------------------------
              // 🤖 INLINE AI SUGGESTIONS
              // ----------------------------------------------------------------
              InlineAiSuggestions(
                onSelect: (action) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => AiActionBottomSheet(
                      content: item.content,
                      userId: item.userId,
                      initialAction: action,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// 🤖 OPEN AI BOTTOM SHEET
  /// -------------------------------------------------------------------------
  void _openAi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          AiActionBottomSheet(content: item.content, userId: item.userId),
    );
  }
}
