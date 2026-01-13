import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/bloc/base_state.dart';
import '../../../../core/bloc/view_state.dart';

import '../../domain/entities/knowledge_item.dart';
import '../../domain/enums/knowledge_type.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';

import '../../../subjects/domain/entities/subject.dart';
import '../../../subjects/presentation/bloc/subject_bloc.dart';

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
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    final item = KnowledgeItem(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      type: widget.type,
      subjectId: _selectedSubjectId,
      isPinned: false,
      createdAt: DateTime.now(),
    );

    context.read<KnowledgeBloc>().add(CreateKnowledgeItemEvent(item));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Text(
              'New ${widget.type.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // ---------- SUBJECT PICKER ----------
            BlocBuilder<SubjectBloc, BaseState<List<Subject>>>(
              builder: (context, state) {
                final viewState = state.viewState;

                if (viewState is! ViewSuccess<List<Subject>>) {
                  return const SizedBox();
                }

                return DropdownButtonFormField<String?>(
                  initialValue: _selectedSubjectId,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.menu_book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No subject'),
                    ),
                    ...viewState.data.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSubjectId = value);
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // ---------- TITLE ----------
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- CONTENT ----------
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------- SAVE BUTTON ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
