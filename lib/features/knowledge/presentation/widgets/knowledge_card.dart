import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
class KnowledgeCard extends StatelessWidget {
  final KnowledgeItem item;

  const KnowledgeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28.r),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        final bloc = context.read<KnowledgeBloc>();
        bloc.add(DeleteKnowledgeItemEvent(item.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => bloc.add(CreateKnowledgeItemEvent(item)),
            ),
          ),
        );
      },
      child: _CardBody(item: item),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete note?'),
            content: const Text('This action cannot be undone.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _CardBody extends StatelessWidget {
  final KnowledgeItem item;

  const _CardBody({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = item.type.color;

    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KnowledgeEditorPage(item: item)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.type.icon, size: 14.r, color: typeColor),
                      SizedBox(width: 6.w),
                      Text(
                        item.type.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (item.isPinned)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Icon(
                      Icons.push_pin,
                      size: 18.r,
                      color: Colors.orange.shade400,
                    ),
                  ),
                _ActionButton(
                  icon: Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  onTap: () => _openAi(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              item.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16.h),
            InlineAiSuggestions(
              onSelect: (action) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28.r),
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
    );
  }

  void _openAi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) =>
          AiActionBottomSheet(content: item.content, userId: item.userId),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.r, color: color),
      ),
    );
  }
}
