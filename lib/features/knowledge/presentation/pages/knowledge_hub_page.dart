import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/knowledge_type.dart';
import '../bloc/knowledge_bloc.dart';
import '../bloc/knowledge_event.dart';
import '../bloc/knowledge_state.dart';
import '../extensions/knowledge_type_ui.dart';

import '../../../subjects/presentation/bloc/subject_bloc.dart';
import '../../../subjects/presentation/bloc/subject_event.dart';

import '../widgets/knowledge_card.dart';
import '../widgets/empty_knowledge_view.dart';
import '../widgets/add_knowledge_bottom_sheet.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';

class KnowledgeHubPage extends StatefulWidget {
  final String userId;

  const KnowledgeHubPage({super.key, required this.userId});

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage> {
  KnowledgeType _currentType = KnowledgeType.note;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
    _loadKnowledge();
  }

  void _onTypeChanged(KnowledgeType type) {
    if (_currentType == type) return;
    setState(() => _currentType = type);
    _loadKnowledge();
  }

  void _loadKnowledge() {
    // If folder mode (no subject selected), we might not load items yet,
    // or we load 'all' to show counts. Ideally we wait for subject selection.
    // However, to keep it simple, we can load 'all' or specific subject.
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => AddKnowledgeBottomSheet(
        userId: widget.userId,
        type: _currentType,
        initialSubjectId: _selectedSubjectId,
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      final value = hex.replaceFirst('#', '');
      return Color(int.parse('FF$value', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subjectState = context.watch<SubjectBloc>().state;

    // 📂 FOLDER MODE LOGIC
    final isFolderMode = _selectedSubjectId == null;
    final subjectName = _selectedSubjectId == null
        ? null
        : subjectState.subjects
              .where((s) => s.id == _selectedSubjectId)
              .firstOrNull
              ?.name;

    return PopScope(
      canPop: !(_selectedSubjectId != null),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _selectedSubjectId = null);
        _loadKnowledge();
      },
      child: Scaffold(
        backgroundColor: colors.surface, // ✅ Theme aware
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ------------------------------------------------------------------
            // 🧠 HEADER & SEARCH
            // ------------------------------------------------------------------
            SliverAppBar.large(
              title: Text(
                isFolderMode ? 'Knowledge Hub' : (subjectName ?? 'Knowledge'),
              ),
              centerTitle: false,
              backgroundColor: colors.surface, // ✅ Theme aware
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: isFolderMode
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() => _selectedSubjectId = null);
                        _loadKnowledge();
                      },
                    ),
              actions: [
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _KnowledgeSearchDelegate(
                        userId: widget.userId,
                        bloc: context.read<KnowledgeBloc>(),
                      ),
                    );
                  },
                  icon: Icon(Icons.search, size: 24.r),
                ),
                SizedBox(width: 8.w),
              ],
            ),

            if (isFolderMode) ...[
              // ------------------------------------------------------------------
              // 🏗️ ADD NEW BUTTON (Home)
              // ------------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      _AiCompanionCard(
                        onTap: () {
                          // potential future action, maybe open search with AI prompt
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Open any note to use AI features!',
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      _AddKnowledgeEntryCard(onTap: _openAddSheet)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------------------------
              // 📂 FOLDER GRID
              // ------------------------------------------------------------------
              BlocBuilder<KnowledgeBloc, KnowledgeState>(
                builder: (context, state) {
                  final uncategorizedCount = state.items
                      .where((e) => e.subjectId == null)
                      .length;

                  return SliverPadding(
                    padding: EdgeInsets.all(16.r),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildListDelegate([
                        // Special Folder: Uncategorized
                        if (uncategorizedCount > 0)
                          _buildFolderCard(
                            context: context,
                            title: 'Uncategorized',
                            subtitle: '$uncategorizedCount items',
                            icon: Icons.folder_open_rounded,
                            color: Colors.grey,
                            onTap: () {
                              setState(
                                () => _selectedSubjectId = 'UNCATEGORIZED',
                              );
                              _loadKnowledge();
                            },
                          ),

                        // Subject Folders
                        ...subjectState.subjects.map((subject) {
                          final color = _hexToColor(subject.color);
                          final count = state.items
                              .where((e) => e.subjectId == subject.id)
                              .length;

                          return _buildFolderCard(
                            context: context,
                            title: subject.name,
                            subtitle: '$count items',
                            icon: Icons.auto_stories_rounded,
                            color: color,
                            onTap: () {
                              setState(() => _selectedSubjectId = subject.id);
                              _loadKnowledge();
                            },
                          );
                        }),
                      ]),
                    ),
                  );
                },
              ),

              if (subjectState.subjects.isEmpty &&
                  !isFolderMode) // Only show empty if not in folder mode or folder mode but no subjects
                const SliverFillRemaining(
                  child: Center(child: Text('No subjects found')),
                ),
            ] else ...[
              // ------------------------------------------------------------------
              // 🏷️ TYPE TABS (Inside Subject)
              // ------------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: KnowledgeType.values.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final type = KnowledgeType.values[index];
                        final isSelected = _currentType == type;
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: isSelected,
                          onSelected: (_) => _onTypeChanged(type),
                          avatar: isSelected
                              ? null
                              : Icon(
                                  type.icon,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                          backgroundColor:
                              colors.surfaceContainerHighest, // ✅ Theme aware
                          selectedColor: colors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ------------------------------------------------------------------
              // 📝 CONTENT LIST (Inside Subject)
              // ------------------------------------------------------------------
              BlocBuilder<KnowledgeBloc, KnowledgeState>(
                builder: (context, state) {
                  if (state.status == KnowledgeStatus.loading &&
                      state.items.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.all(16.r),
                      sliver: SliverList.separated(
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) =>
                            const ListItemSkeleton(),
                      ),
                    );
                  }

                  if (state.status == KnowledgeStatus.failure) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong',
                        ),
                      ),
                    );
                  }

                  if (state.items.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyKnowledgeView(type: _currentType),
                    );
                  }

                  final pinned = state.items.where((e) => e.isPinned).toList();
                  final normal = state.items.where((e) => !e.isPinned).toList();

                  return SliverPadding(
                    padding: EdgeInsets.all(16.r),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (pinned.isNotEmpty) ...[
                          const _SectionHeader(
                            title: 'Pinned',
                            icon: Icons.push_pin,
                          ),
                          ...pinned.map((e) => KnowledgeCard(item: e)),
                          SizedBox(height: 16.h),
                        ],
                        if (normal.isNotEmpty) ...[
                          if (pinned.isNotEmpty)
                            const _SectionHeader(
                              title: 'All Notes',
                              icon: Icons.notes,
                            ),
                          ...normal.map((e) => KnowledgeCard(item: e)),
                        ],
                        SizedBox(height: 80.h), // Fab space backup
                      ]),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        floatingActionButton: isFolderMode
            ? null
            : FloatingActionButton.extended(
                onPressed: _openAddSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Note'),
              ),
      ),
    );
  }

  Widget _buildFolderCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 36.r),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 8.w),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
              letterSpacing: 0.5,
            ),
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
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capture Idea',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Create note, summary, or flashcard',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _KnowledgeSearchDelegate extends SearchDelegate {
  final String userId;
  final KnowledgeBloc bloc;

  _KnowledgeSearchDelegate({required this.userId, required this.bloc});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Type to search notes & summaries'));
    }

    // Trigger search in Bloc
    bloc.add(LoadKnowledgeItemsEvent(userId: userId, query: query));

    return BlocBuilder<KnowledgeBloc, KnowledgeState>(
      bloc: bloc,
      builder: (context, state) {
        if (state.status == KnowledgeStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            return KnowledgeCard(item: state.items[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.manage_search_rounded,
          size: 80,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Search across all folders',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiCompanionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AiCompanionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14.r,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'AI POWERED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Unlock Knowledge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Summarize notes & generate quizzes instantly.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF6366F1),
                size: 24.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
