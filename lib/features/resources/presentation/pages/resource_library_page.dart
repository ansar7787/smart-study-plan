import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/core/bloc/base_state.dart';
import 'package:smart_study_plan/core/bloc/view_state.dart';
import 'package:smart_study_plan/features/resources/presentation/pages/resource_viewer_page.dart';
import 'package:smart_study_plan/features/resources/presentation/pages/upload_resource_page.dart';
import 'package:smart_study_plan/features/subjects/domain/entities/subject.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_event.dart';

import '../../domain/entities/file_resource.dart';
import '../bloc/resource_bloc.dart';
import '../bloc/resource_event.dart';
import '../widgets/resource_item_card.dart';

class ResourceLibraryPage extends StatefulWidget {
  final String userId;

  const ResourceLibraryPage({super.key, required this.userId});

  @override
  State<ResourceLibraryPage> createState() => _ResourceLibraryPageState();
}

class _ResourceLibraryPageState extends State<ResourceLibraryPage> {
  String? _selectedSubjectId;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
    context.read<SubjectBloc>().add(LoadSubjectsEvent(widget.userId));
  }

  void _loadResources() {
    if (_selectedSubjectId == null) {
      context.read<ResourceBloc>().add(LoadResourcesByUserEvent(widget.userId));
    } else {
      context.read<ResourceBloc>().add(
        LoadResourcesBySubjectEvent(_selectedSubjectId!),
      );
    }
  }

  void _openUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadResourcePage(
          userId: widget.userId,
          subjectId: _selectedSubjectId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            /// 🌟 HEADER
            _HeaderSection(onUpload: _openUpload),

            /// 🧭 FILTERS
            _FilterSection(
              showFavoritesOnly: _showFavoritesOnly,
              onFavoritesChanged: (v) => setState(() => _showFavoritesOnly = v),
              selectedSubjectId: _selectedSubjectId,
              onSubjectChanged: (id) {
                setState(() => _selectedSubjectId = id);
                _loadResources();
              },
            ),

            /// 📂 CONTENT
            Expanded(
              child: BlocBuilder<ResourceBloc, BaseState<List<FileResource>>>(
                builder: (context, state) {
                  final vs = state.viewState;

                  if (vs is ViewLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vs is ViewFailure<List<FileResource>>) {
                    return Center(child: Text(vs.message));
                  }

                  if (vs is ViewSuccess<List<FileResource>>) {
                    var items = vs.data;

                    if (_showFavoritesOnly) {
                      items = items.where((e) => e.isFavorite).toList();
                    }

                    if (items.isEmpty) {
                      return _EmptyResources(onAdd: _openUpload);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final resource = items[i];

                        return _SwipeDeleteWrapper(
                          resource: resource,
                          child: ResourceItemCard(
                            resource: resource,
                            onFavorite: () {
                              context.read<ResourceBloc>().add(
                                ToggleFavoriteResourceEvent(resource),
                              );
                            },
                            onOpen: () {
                              if (resource.url.isEmpty) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ResourceViewerPage(resource: resource),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onUpload;

  const _HeaderSection({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Resources',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Store PDFs, images & notes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          /// 🚀 UPLOAD CARD
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onUpload,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_upload_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Upload a new resource',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final bool showFavoritesOnly;
  final ValueChanged<bool> onFavoritesChanged;
  final String? selectedSubjectId;
  final ValueChanged<String?> onSubjectChanged;

  const _FilterSection({
    required this.showFavoritesOnly,
    required this.onFavoritesChanged,
    required this.selectedSubjectId,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ⭐ FAVORITES TOGGLE
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onFavoritesChanged(!showFavoritesOnly),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: showFavoritesOnly
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surface,
                border: Border.all(
                  color: showFavoritesOnly
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                    color: showFavoritesOnly ? Colors.red : colors.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Show favorites only',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: showFavoritesOnly,
                    onChanged: onFavoritesChanged,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// 📘 SUBJECT FILTERS
          _SubjectChips(
            selectedId: selectedSubjectId,
            onSelected: onSubjectChanged,
          ),
        ],
      ),
    );
  }
}

class _SubjectChips extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _SubjectChips({required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectBloc, BaseState<List<Subject>>>(
      builder: (context, state) {
        final vs = state.viewState;
        if (vs is! ViewSuccess<List<Subject>>) return const SizedBox();

        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip(
                label: 'All',
                selected: selectedId == null,
                onTap: () => onSelected(null),
              ),
              const SizedBox(width: 8),
              ...vs.data.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(
                    label: s.name,
                    selected: selectedId == s.id,
                    onTap: () => onSelected(s.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SwipeDeleteWrapper extends StatelessWidget {
  final Widget child;
  final FileResource resource;

  const _SwipeDeleteWrapper({required this.child, required this.resource});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ResourceBloc>();

    return Dismissible(
      key: ValueKey(resource.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();

        bloc.add(SoftDeleteResourceEvent(resource));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${resource.name}" to trash'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                bloc.add(RestoreResourceEvent(resource));
              },
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyResources extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyResources({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- ICON ----------
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.18),
                    colors.secondary.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 64,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 18),

            // ---------- TITLE ----------
            Text(
              'No study resources yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // ---------- DESCRIPTION ----------
            Text(
              'Add PDFs, images, notes or documents.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            // ---------- PRIMARY ACTION ----------
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.cloud_upload),
              label: const Text(
                'Add your first resource',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- HELPER TEXT ----------
            Text(
              'PDF • Image • Doc • Notes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
