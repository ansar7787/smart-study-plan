import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';

class CreateSessionPage extends StatefulWidget {
  final String userId;
  final StudySession? session;

  const CreateSessionPage({super.key, required this.userId, this.session});

  bool get isEdit => session != null;

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool _isRecurring = false;
  String _recurrencePattern = 'daily';

  @override
  void initState() {
    super.initState();

    final s = widget.session;

    _titleController = TextEditingController(text: s?.title ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');

    _selectedDate = s?.startTime ?? DateTime.now();
    _startTime = TimeOfDay.fromDateTime(s?.startTime ?? DateTime.now());
    _endTime = TimeOfDay.fromDateTime(
      s?.endTime ?? DateTime.now().add(const Duration(hours: 1)),
    );

    _isRecurring = s?.isRecurring ?? false;
    _recurrencePattern = s?.recurrencePattern ?? 'daily';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Session' : 'New Study Session'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionCard(
                      child: Column(
                        children: [
                          _TitleField(controller: _titleController),
                          const SizedBox(height: 12),
                          _DescriptionField(controller: _descriptionController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _SectionCard(
                      child: Column(
                        children: [
                          _PickerTile(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: DateFormat.yMMMMd().format(_selectedDate),
                            onTap: () => _pickDate(context),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerTile(
                                  icon: Icons.access_time,
                                  label: 'Start',
                                  value: _startTime.format(context),
                                  onTap: () => _pickStartTime(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerTile(
                                  icon: Icons.access_time,
                                  label: 'End',
                                  value: _endTime.format(context),
                                  onTap: () => _pickEndTime(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _SectionCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Recurring Session'),
                            value: _isRecurring,
                            onChanged: (v) => setState(() => _isRecurring = v),
                          ),
                          if (_isRecurring) ...[
                            const Divider(),
                            DropdownButtonFormField<String>(
                              initialValue: _recurrencePattern,
                              decoration: const InputDecoration(
                                labelText: 'Repeat',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'daily',
                                  child: Text('Daily'),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text('Weekly'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _recurrencePattern = v!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔥 BOTTOM ACTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  child: Text(
                    widget.isEdit ? 'Update Session' : 'Create Session',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PICKERS ----------------

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  // ---------------- SAVE ----------------

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final session = StudySession(
      id:
          widget.session?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.userId,
      subjectId: widget.session?.subjectId ?? 'general',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: start,
      endTime: end,
      isRecurring: _isRecurring,
      recurrencePattern: _isRecurring ? _recurrencePattern : null,
      createdAt: widget.session?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bloc = context.read<PlannerBloc>();

    if (widget.isEdit) {
      bloc.add(UpdateSessionEvent(session));
    } else {
      bloc.add(CreateSessionEvent(session));
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

class _TitleField extends StatelessWidget {
  final TextEditingController controller;

  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Session Title'),
      validator: (v) => v == null || v.trim().isEmpty ? 'Title required' : null,
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Description (optional)'),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
