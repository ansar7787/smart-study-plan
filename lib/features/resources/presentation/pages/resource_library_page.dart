import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/resources/presentation/pages/resource_viewer_page.dart';
import 'package:smart_study_plan/features/resources/presentation/pages/upload_resource_page.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_event.dart';

import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';
import '../../domain/entities/file_resource.dart';
import '../bloc/resource_bloc.dart';
import '../bloc/resource_event.dart';
import '../bloc/resource_state.dart';
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
    } else if (_selectedSubjectId == 'ALL') {
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subjectState = context.watch<SubjectBloc>().state;

    // 📂 SUBJECT (FOLDER) MODE
    final isFolderMode = _selectedSubjectId == null && !_showFavoritesOnly;
    final isInsideFolder = _selectedSubjectId != null;

    return PopScope(
      canPop: !isInsideFolder,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        setState(() => _selectedSubjectId = null);
        _loadResources();
      },
      child: Scaffold(
        backgroundColor: colors.surface, // ✅ Theme aware
        body: SafeArea(
          child: Column(
            children: [
              /// 🌟 HEADER
              _HeaderSection(
                onUpload: _openUpload,
                isFolderMode: isFolderMode,
                selectedSubjectId: _selectedSubjectId,
                subjectName: _selectedSubjectId == 'ALL'
                    ? 'All Files'
                    : subjectState.subjects
                          .where((s) => s.id == _selectedSubjectId)
                          .firstOrNull
                          ?.name,
                onBack: () {
                  setState(() => _selectedSubjectId = null);
                  _loadResources();
                },
              ),

              /// 🧭 FAVORITES TOGGLE (Only in folder mode or if favs active)
              if (_selectedSubjectId == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FavoritesFilter(
                    showFavoritesOnly: _showFavoritesOnly,
                    onChanged: (v) => setState(() => _showFavoritesOnly = v),
                  ),
                ),

              const SizedBox(height: 12),

              /// 📂 CONTENT
              Expanded(
                child: BlocBuilder<ResourceBloc, ResourceState>(
                  builder: (context, state) {
                    // --- LOADING ---
                    if (state.status == ResourceStatus.loading &&
                        state.resources.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (_, index) => const ListItemSkeleton(),
                      );
                    }

                    // --- FOLDER GRID VIEW ---
                    if (isFolderMode) {
                      if (subjectState.subjects.isEmpty) {
                        return _EmptyResources(onAdd: _openUpload);
                      }
                      return _FolderGrid(
                        subjects: subjectState.subjects,
                        resources: state.resources,
                        onFolderTap: (id) {
                          setState(() => _selectedSubjectId = id);
                          _loadResources();
                        },
                        onViewAll: () {
                          setState(() => _selectedSubjectId = 'ALL');
                          _loadResources();
                        },
                      );
                    }

                    // --- RESOURCE LIST VIEW ---
                    var items = state.resources;
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onUpload;
  final bool isFolderMode;
  final String? selectedSubjectId;
  final String? subjectName;
  final VoidCallback onBack;

  const _HeaderSection({
    required this.onUpload,
    required this.isFolderMode,
    required this.selectedSubjectId,
    this.subjectName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (selectedSubjectId != null)
                IconButton.filledTonal(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),

              if (selectedSubjectId == null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resources',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Manage your files',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              // UPLOAD BUTTON (Small)
              IconButton(
                onPressed: onUpload,
                icon: const Icon(Icons.cloud_upload_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),

          if (selectedSubjectId == null) ...[
            const SizedBox(height: 16),
            const _StorageUsageIndicator(),
          ],

          if (selectedSubjectId != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  subjectName ?? 'Unknown Subject',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoritesFilter extends StatelessWidget {
  final bool showFavoritesOnly;
  final ValueChanged<bool> onChanged;

  const _FavoritesFilter({
    required this.showFavoritesOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!showFavoritesOnly),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: showFavoritesOnly
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainer,
          border: Border.all(
            color: showFavoritesOnly
                ? colors.primary
                : colors.outline.withValues(alpha: 0.2),
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
            Switch(value: showFavoritesOnly, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _FolderGrid extends StatelessWidget {
  final List<dynamic> subjects;
  final List<FileResource> resources;
  final ValueChanged<String> onFolderTap;
  final VoidCallback onViewAll;

  const _FolderGrid({
    required this.subjects,
    required this.resources,
    required this.onFolderTap,
    required this.onViewAll,
  });

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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: subjects.length + 1, // +1 for "All Files"
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.all_inbox_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Files',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'View everything',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final subject = subjects[index - 1];
        final color = _hexToColor(subject.color);

        return InkWell(
          onTap: () => onFolderTap(subject.id),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.folder_rounded, color: color, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resources.where((r) => r.subjectId == subject.id).length} files',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

class _StorageUsageIndicator extends StatelessWidget {
  const _StorageUsageIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceBloc, ResourceState>(
      builder: (context, state) {
        final used = state.totalStorageUsed;
        const max = 250.0 * 1024 * 1024;
        final progress = (used / max).clamp(0.0, 1.0);
        final percent = (progress * 100).toInt();

        final usedMb = (used / (1024 * 1024)).toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Storage Usage',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.9
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$usedMb MB of 250 MB used',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
