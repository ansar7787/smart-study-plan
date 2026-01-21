import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/knowledge/domain/usecases/create_tasks_from_ai_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/extracted_task.dart';

class AiTasksPreviewSheet extends StatefulWidget {
  final String userId;
  final List<ExtractedTask> tasks;

  const AiTasksPreviewSheet({
    super.key,
    required this.userId,
    required this.tasks,
  });

  @override
  State<AiTasksPreviewSheet> createState() => _AiTasksPreviewSheetState();
}

class _AiTasksPreviewSheetState extends State<AiTasksPreviewSheet> {
  String _selectedSubjectId = 'unassigned';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- HEADER ----------
          Text(
            'Create Tasks from AI',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),

          // ---------- SUBJECT PICKER (BONUS UX) ----------
          DropdownButtonFormField<String>(
            initialValue: _selectedSubjectId,
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'unassigned', child: Text('Unassigned')),
              // 🔥 You can dynamically load subjects here later
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSubjectId = value);
              }
            },
          ),

          SizedBox(height: 16.h),

          // ---------- TASK LIST ----------
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.tasks.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final task = widget.tasks[index];
                return ListTile(
                  leading: Icon(Icons.task_alt, size: 24.r),
                  title: Text(task.title, style: TextStyle(fontSize: 14.sp)),
                  subtitle:
                      task.description != null && task.description!.isNotEmpty
                      ? Text(
                          task.description!,
                          style: TextStyle(fontSize: 12.sp),
                        )
                      : null,
                );
              },
            ),
          ),

          SizedBox(height: 20.h),

          // ---------- ACTIONS ----------
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTasks,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 18.r,
                          width: 18.r,
                          child: CircularProgressIndicator(strokeWidth: 2.r),
                        )
                      : Text('Create Tasks', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- CREATE TASKS ----------
  Future<void> _createTasks() async {
    setState(() => _isLoading = true);

    final usecase = context.read<CreateTasksFromAiUseCase>();

    final result = await usecase(
      userId: widget.userId,
      tasks: widget.tasks,
      subjectId: _selectedSubjectId,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (Failure failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks created successfully')),
        );
      },
    );
  }
}
