import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';

import '../../domain/entities/subject.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';

class SubjectFormPage extends StatefulWidget {
  final Subject? subject;
  final String userId;

  const SubjectFormPage({super.key, this.subject, required this.userId});

  bool get isEdit => subject != null;

  @override
  State<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _teacher;
  late final TextEditingController _credits;
  late final TextEditingController _semester;

  Color _color = const Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    final s = widget.subject;

    _name = TextEditingController(text: s?.name ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _teacher = TextEditingController(text: s?.teacher ?? '');
    _credits = TextEditingController(text: s?.credits.toString() ?? '0');
    _semester = TextEditingController(text: s?.semester ?? '');

    if (s != null) {
      _color = Color(
        int.parse('FF${s.color.replaceFirst('#', '')}', radix: 16),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _teacher.dispose();
    _credits.dispose();
    _semester.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    final subject = Subject(
      id: widget.subject?.id ?? const Uuid().v4(),
      userId: widget.userId,
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      teacher: _teacher.text.trim().isEmpty ? null : _teacher.text.trim(),
      semester: _semester.text.trim().isEmpty ? null : _semester.text.trim(),
      credits: int.parse(_credits.text.trim()),
      color:
          '#${_color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      createdAt: widget.subject?.createdAt ?? now,
      updatedAt: now,
    );

    final bloc = context.read<SubjectBloc>();

    if (widget.isEdit) {
      bloc.add(UpdateSubjectEvent(subject));
    } else {
      bloc.add(CreateSubjectEvent(subject));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Subject' : 'New Subject'),
      ),
      body: BlocListener<SubjectBloc, BaseState<List<Subject>>>(
        listener: (context, state) {
          final viewState = state.viewState;
          if (viewState is ViewSuccess<List<Subject>>) {
            Navigator.pop(context);
          }
          if (viewState is ViewFailure<List<Subject>>) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(viewState.message)));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SectionCard(
                child: Column(
                  children: [
                    _Field(
                      controller: _name,
                      label: 'Subject name',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      controller: _description,
                      label: 'Description',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                child: Column(
                  children: [
                    _Field(controller: _teacher, label: 'Teacher'),
                    const SizedBox(height: 12),
                    _Field(
                      controller: _credits,
                      label: 'Credits',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Invalid number'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _Field(controller: _semester, label: 'Semester'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                child: _ColorPicker(
                  selected: _color,
                  onSelect: (c) => setState(() => _color = c),
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔥 FIXED SAVE BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _save,
            child: Text(widget.isEdit ? 'Update Subject' : 'Create Subject'),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               UI HELPERS                                   */
/* -------------------------------------------------------------------------- */

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

/* ------------------------------- TEXT FIELD -------------------------------- */

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/* ------------------------------ COLOR PICKER ------------------------------- */

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF14B8A6), // Teal
      const Color(0xFF64748B), // Slate
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject Color',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final isSelected = c.toARGB32() == selected.toARGB32();

            return GestureDetector(
              onTap: () => onSelect(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
