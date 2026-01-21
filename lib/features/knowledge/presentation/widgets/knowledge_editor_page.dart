import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/knowledge_item.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../extensions/knowledge_type_ui.dart';

class KnowledgeEditorPage extends StatefulWidget {
  final KnowledgeItem item;

  const KnowledgeEditorPage({super.key, required this.item});

  @override
  State<KnowledgeEditorPage> createState() => _KnowledgeEditorPageState();
}

class _KnowledgeEditorPageState extends State<KnowledgeEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _contentCtrl = TextEditingController(text: widget.item.content);

    _titleCtrl.addListener(_onChange);
    _contentCtrl.addListener(_onChange);
  }

  void _onChange() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _save() {
    context.read<KnowledgeBloc>().add(
      UpdateKnowledgeItemEvent(
        widget.item.copyWith(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = widget.item.type;
    final accent = type.color;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldDiscard = await _confirmDiscardChanges();
        if (shouldDiscard && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        // ------------------------------------------------------------------
        // 🌈 COLORFUL HEADER (NOT BORING)
        // ------------------------------------------------------------------
        appBar: AppBar(
          elevation: 0,
          backgroundColor: accent.withValues(alpha: 0.10),
          foregroundColor: accent,
          title: Text('Edit ${type.label}', style: TextStyle(fontSize: 18.sp)),
        ),

        // ------------------------------------------------------------------
        // 💾 BOTTOM SAVE BAR (BETTER THAN FAB)
        // ------------------------------------------------------------------
        bottomNavigationBar: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                if (_isDirty)
                  BoxShadow(
                    blurRadius: 20.r,
                    color: accent.withValues(alpha: 0.25),
                  ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _isDirty ? _save : null,
              icon: Icon(Icons.check, size: 20.r),
              label: Text(
                'Save changes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),

        // ------------------------------------------------------------------
        // ✍️ EDITOR BODY
        // ------------------------------------------------------------------
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            children: [
              // --------------------------------------------------------------
              // 🏷️ TITLE FIELD
              // --------------------------------------------------------------
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: TextField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // --------------------------------------------------------------
              // 📝 CONTENT FIELD
              // --------------------------------------------------------------
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  minLines: 10,
                  keyboardType: TextInputType.multiline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: 16.sp,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Start writing your thoughts here…',
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // --------------------------------------------------------------
              // ℹ️ HELPER TEXT
              // --------------------------------------------------------------
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16.r, color: accent),
                  SizedBox(width: 6.w),
                  Text(
                    'Changes are saved only when you tap Save',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
