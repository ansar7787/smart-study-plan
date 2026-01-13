import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_event.dart';

import '../../../../core/bloc/base_state.dart';
import '../../../../core/bloc/view_state.dart';

import '../../domain/enums/knowledge_type.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../bloc/knowledge_state.dart';

import '../../../subjects/domain/entities/subject.dart';
import '../../../subjects/presentation/bloc/subject_bloc.dart';

import '../widgets/knowledge_card.dart';
import '../widgets/knowledge_tabs.dart';
import '../widgets/empty_knowledge_view.dart';
import '../widgets/add_knowledge_bottom_sheet.dart';

class KnowledgeHubPage extends StatefulWidget {
  final String userId;

  const KnowledgeHubPage({super.key, required this.userId});

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  KnowledgeType _currentType = KnowledgeType.note;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: KnowledgeType.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);

    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
    _loadKnowledge();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      _currentType = KnowledgeType.values[_tabController.index];
    });

    _loadKnowledge();
  }

  void _loadKnowledge() {
    context.read<KnowledgeBloc>().add(
      LoadKnowledgeItemsEvent(
        userId: widget.userId,
        type: _currentType,
        subjectId: _selectedSubjectId,
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddKnowledgeBottomSheet(
        userId: widget.userId,
        type: _currentType,
        initialSubjectId: _selectedSubjectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F7FB),
        automaticallyImplyLeading: false,
        title: const Text('Knowledge Hub'),
        centerTitle: true,
        bottom: KnowledgeTabs(controller: _tabController),
      ),

      // ❌ FAB REMOVED
      body: Column(
        children: [
          _AddKnowledgeEntryCard(onTap: _openAddSheet),

          _SubjectFilter(
            selectedSubjectId: _selectedSubjectId,
            onChanged: (id) {
              setState(() => _selectedSubjectId = id);
              _loadKnowledge();
            },
          ),

          Expanded(
            child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
              builder: (context, state) {
                if (state is KnowledgeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is KnowledgeLoaded) {
                  if (state.items.isEmpty) {
                    return EmptyKnowledgeView(type: _currentType);
                  }

                  final pinned = state.items.where((e) => e.isPinned).toList();
                  final normal = state.items.where((e) => !e.isPinned).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        const _SectionHeader(
                          title: 'Pinned',
                          icon: Icons.push_pin,
                        ),
                        const SizedBox(height: 8),
                        ...pinned.map((e) => KnowledgeCard(item: e)),
                        const SizedBox(height: 20),
                      ],
                      if (normal.isNotEmpty)
                        const _SectionHeader(
                          title: 'All Notes',
                          icon: Icons.notes,
                        ),
                      const SizedBox(height: 8),
                      ...normal.map((e) => KnowledgeCard(item: e)),
                    ],
                  );
                }

                if (state is KnowledgeError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  final String? selectedSubjectId;
  final ValueChanged<String?> onChanged;

  const _SubjectFilter({
    required this.selectedSubjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectBloc, BaseState<List<Subject>>>(
      builder: (context, state) {
        final viewState = state.viewState;

        if (viewState is! ViewSuccess<List<Subject>>) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: DropdownButtonFormField<String?>(
            initialValue: selectedSubjectId,
            decoration: InputDecoration(
              labelText: 'Filter by subject',
              prefixIcon: const Icon(Icons.menu_book),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All subjects')),
              ...viewState.data.map(
                (subject) => DropdownMenuItem(
                  value: subject.id,
                  child: Text(subject.name),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AddKnowledgeEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddKnowledgeEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add new knowledge...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
