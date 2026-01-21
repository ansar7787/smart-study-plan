import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  final String? subjectId;
  final String userId;

  const TaskFormPage({
    super.key,
    this.task,
    this.subjectId,
    required this.userId,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _startDate;
  late DateTime _endDate;

  int _priority = 2;
  String _status = 'todo';

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    // Default: Start now, End +1 hour
    final now = DateTime.now();
    _startDate = widget.task?.startDate?.toLocal() ?? now;
    _endDate =
        widget.task?.dueDate.toLocal() ?? now.add(const Duration(hours: 1));

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

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subjectId: widget.task?.subjectId ?? widget.subjectId!,
      userId: widget.task?.userId ?? widget.userId,
      startDate: _startDate, // NEW
      dueDate: _endDate, // Mapped to End Date
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

    // ⏰ AUTO-ALARM (30 mins before due)
    _scheduleAutoAlarm(task);
  }

  Future<void> _scheduleAutoAlarm(Task task) async {
    // 1. Calculate trigger time
    final reminderTime = task.dueDate.subtract(const Duration(minutes: 30));

    // 2. Validate time
    if (reminderTime.isBefore(DateTime.now())) {
      return; // Creating a task that's already effectively "due" for alarm -> Skip
    }

    // 3. Generate Reminder ID (reuse existing or new? Simple: new for auto)
    // Careful: If editing, we might duplicate.
    // Ideally we check if one exists. But for "Auto-add", let's assuming we just add one if it's new.
    // User asked "also implement... also add".
    // To be safe and avoid duplicates on Edit without complex checks:
    // Only easy way without reading all reminders is to just schedule AlarmService (id is task-based).
    // And Fire-and-forget the ReminderBloc event.
    // Actually, `AlarmService.scheduleTaskAlarm` uses `taskId.hashCode` so it overwrites! perfect.
    // For `ReminderBloc`, we might create duplicate entries in DB if we blindly add.
    // Is it acceptable to just set the ALARM (notification) without the DB Reminder entity?
    // The user motivation is "alarm". The Reminder entity is for the UI list.
    // Let's do BOTH but wrap in a try/catch or just optimistic.
    // For now, I will just set the AlarmService which is the critical part for the "alarm".
    // Syncing to ReminderBloc might be noise if user didn't explicitly ask for "Reminder List Item".
    // But "before 30 minutes due alarm" implies a reminder.
    // I'll add both.

    // Note: Creating a unique ID for the Reminder entity is tricky without duplication checks.
    // I'll fallback to: Set Alarm + Show SnackBar "Auto-alarm set".
    // I won't create a DB Reminder entity to avoid clutter/dupes until I have a better "Get/Check" mechanism in this form.
    // Wait, the user might want to see it in the list.
    // Let's stick to AlarmService ONLY for now to ensure the "Ring" happens.

    final alarmId = const Uuid()
        .v4(); // Dummy if not saving to DB, but AlarmService needs one?
    // AlarmService.scheduleTaskAlarm checks taskId.hashCode, but takes `reminderId` arg.
    // Let's pass a new UUID.

    await AlarmService.instance.scheduleTaskAlarm(
      taskId: task.id,
      taskTitle: task.title,
      reminderId: alarmId,
      reminderTime: reminderTime,
    );

    // Optional: Notify user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm set for 30 mins before due'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state.status == TaskStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.status == TaskStatus.success) {
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

          // START DATE
          _DateTimeField(
            label: 'Start Date & Time',
            dateTime: _startDate,
            onTap: () => _pickDateTime(
              initial: _startDate,
              firstDate: DateTime.now(), // Disable past dates
              onPicked: (dt) {
                setState(() {
                  _startDate = dt;
                  // Auto-adjust End Date if it becomes invalid
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate.add(const Duration(hours: 1));
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // END DATE
          _DateTimeField(
            label: 'End Date & Time',
            dateTime: _endDate,
            onTap: () => _pickDateTime(
              initial: _endDate,
              firstDate: _startDate, // Disable dates before Start Date
              onPicked: (dt) {
                // Ensure strict future check for time as well
                if (dt.isBefore(_startDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time cannot be before Start time'),
                    ),
                  );
                  return;
                }
                setState(() => _endDate = dt);
              },
            ),
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

  Future<void> _pickDateTime({
    required DateTime initial,
    DateTime? firstDate,
    required Function(DateTime) onPicked,
  }) async {
    final first = firstDate ?? DateTime(2000);

    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onPicked(picked);
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dt = dateTime.toLocal();
    final dateStr = DateFormat.yMMMd().add_jm().format(dt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.event),
        ),
        child: Text(dateStr, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
