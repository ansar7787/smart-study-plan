import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/file_resource.dart';

class ResourceItemCard extends StatelessWidget {
  final FileResource resource;
  final VoidCallback onFavorite;
  final VoidCallback? onOpen;

  const ResourceItemCard({
    super.key,
    required this.resource,
    required this.onFavorite,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _fileColors(resource.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FileBadge(icon: colors.icon, color: colors.main),
                const SizedBox(width: 14),
                Expanded(child: _Content(resource, colors)),
                _FavoriteButton(
                  isFavorite: resource.isFavorite,
                  onPressed: onFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= CONTENT =================

class _Content extends StatelessWidget {
  final FileResource resource;
  final _FileColorSet colors;

  const _Content(this.resource, this.colors);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM dd').format(resource.createdAt);
    final size = _formatSize(resource.size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resource.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _InfoChip(label: resource.type.toUpperCase(), color: colors.main),
            _InfoChip(label: size, color: Colors.grey, light: true),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Added $date',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// ================= FILE BADGE =================

class _FileBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FileBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

/// ================= FAVORITE BUTTON =================

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 22,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite ? Colors.amber : Colors.grey.shade500,
          size: 24,
        ),
      ),
    );
  }
}

/// ================= CHIP =================

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool light;

  const _InfoChip({
    required this.label,
    required this.color,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light
            ? Colors.grey.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: light ? Colors.grey.shade700 : color,
        ),
      ),
    );
  }
}

/// ================= COLOR LOGIC =================

class _FileColorSet {
  final Color main;
  final Color bg;
  final IconData icon;

  _FileColorSet(this.main, this.bg, this.icon);
}

_FileColorSet _fileColors(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return _FileColorSet(
        Colors.red.shade600,
        Colors.red.shade100,
        Icons.picture_as_pdf_rounded,
      );
    case 'image':
      return _FileColorSet(
        Colors.blue.shade600,
        Colors.blue.shade100,
        Icons.image_rounded,
      );
    case 'doc':
    case 'docx':
      return _FileColorSet(
        Colors.indigo.shade600,
        Colors.indigo.shade100,
        Icons.description_rounded,
      );
    default:
      return _FileColorSet(
        Colors.grey.shade700,
        Colors.grey.shade300,
        Icons.insert_drive_file_rounded,
      );
  }
}
