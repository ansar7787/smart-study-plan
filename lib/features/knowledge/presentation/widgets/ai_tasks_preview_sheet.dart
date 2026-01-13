import 'package:flutter/material.dart';
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
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- HEADER ----------
          const Text(
            'Create Tasks from AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ---------- SUBJECT PICKER (BONUS UX) ----------
          DropdownButtonFormField<String>(
            initialValue: _selectedSubjectId,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
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

          const SizedBox(height: 16),

          // ---------- TASK LIST ----------
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.tasks.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final task = widget.tasks[index];
                return ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: Text(task.title),
                  subtitle:
                      task.description != null && task.description!.isNotEmpty
                      ? Text(task.description!)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ---------- ACTIONS ----------
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTasks,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Tasks'),
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
