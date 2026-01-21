import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/knowledge_item.dart';
import '../../domain/enums/knowledge_type.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../extensions/knowledge_type_ui.dart';

import '../../../subjects/presentation/bloc/subject_bloc.dart';
import '../../../subjects/presentation/bloc/subject_state.dart';

class AddKnowledgeBottomSheet extends StatefulWidget {
  final String userId;
  final KnowledgeType type;
  final String? initialSubjectId;

  const AddKnowledgeBottomSheet({
    super.key,
    required this.userId,
    required this.type,
    this.initialSubjectId,
  });

  @override
  State<AddKnowledgeBottomSheet> createState() =>
      _AddKnowledgeBottomSheetState();
}

class _AddKnowledgeBottomSheetState extends State<AddKnowledgeBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  String? _selectedSubjectId;
  String? _titleError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    setState(() {
      _titleError = title.isEmpty ? 'Title cannot be empty' : null;
      _contentError = content.isEmpty ? 'Content cannot be empty' : null;
    });

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    final item = KnowledgeItem(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: title,
      content: content,
      type: widget.type,
      subjectId: _selectedSubjectId,
      isPinned: false,
      createdAt: DateTime.now(),
    );

    context.read<KnowledgeBloc>().add(CreateKnowledgeItemEvent(item));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note added successfully'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24.w,
          24.h,
          24.w,
          viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- HANDLE ----------
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ---------- HEADER ----------
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      widget.type.icon,
                      color: colors.primary,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New ${widget.type.label}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                        ),
                        Text(
                          'Add to your knowledge base',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // ---------- SUBJECT PICKER ----------
              BlocBuilder<SubjectBloc, SubjectState>(
                builder: (context, state) {
                  if (state.status != SubjectStatus.success) {
                    return const SizedBox();
                  }

                  return DropdownButtonFormField<String?>(
                    initialValue: _selectedSubjectId,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.folder_open_rounded, size: 20.r),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    dropdownColor: colors.surfaceContainer,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Uncategorized',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      ...state.subjects.map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.name,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSubjectId = value);
                    },
                  );
                },
              ),

              SizedBox(height: 16.h),

              // ---------- TITLE ----------
              TextField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: _titleError,
                  prefixIcon: Icon(Icons.title_rounded, size: 20.r),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16.r),
                ),
              ),

              SizedBox(height: 16.h),

              // ---------- CONTENT ----------
              TextField(
                controller: _contentCtrl,
                maxLines: 8,
                minLines: 4,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15.sp),
                decoration: InputDecoration(
                  labelText: 'Write your thoughts...',
                  errorText: _contentError,
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60.h),
                    child: Icon(Icons.description_rounded, size: 20.r),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16.r),
                ),
              ),

              SizedBox(height: 32.h),

              // ---------- SAVE BUTTON ----------
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Save Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
