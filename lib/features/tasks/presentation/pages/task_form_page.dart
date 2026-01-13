import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/bloc/base_state.dart';
import '../../../../core/bloc/view_state.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  final String? subjectId;

  const TaskFormPage({super.key, this.task, this.subjectId});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  int _priority = 2;
  String _status = 'todo';

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    _priority = widget.task?.priority ?? 2;
    _status = widget.task?.status ?? 'todo';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task title is required')));
      return;
    }

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subjectId: widget.task?.subjectId ?? widget.subjectId!,
      userId: widget.task?.userId ?? '',
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      isCompleted: _status == 'completed',
      tags: widget.task?.tags ?? [],
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.task == null) {
      context.read<TaskBloc>().add(CreateTaskEvent(task));
    } else {
      context.read<TaskBloc>().add(UpdateTaskEvent(task));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: BlocListener<TaskBloc, BaseState<List<Task>>>(
        listener: (context, state) {
          final viewState = state.viewState;

          if (viewState is ViewFailure<List<Task>>) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(viewState.message)));
          }

          if (viewState is ViewSuccess<List<Task>>) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.task == null
                      ? 'Task created successfully'
                      : 'Task updated successfully',
                ),
              ),
            );
          }
        },
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due Date'),
            subtitle: Text(
              '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: _priority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Low')),
              DropdownMenuItem(value: 2, child: Text('Medium')),
              DropdownMenuItem(value: 3, child: Text('High')),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 2),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'todo', child: Text('To Do')),
              DropdownMenuItem(
                value: 'in_progress',
                child: Text('In Progress'),
              ),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'todo'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }
}
