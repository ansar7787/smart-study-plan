import 'package:flutter/material.dart';
import '../../domain/entities/subject.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onEdit; // TAP CARD
  final VoidCallback onViewTasks; // BUTTON
  final VoidCallback onDelete; // SWIPE

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onViewTasks,
    required this.onDelete,
  });

  Color _hexToColor(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _hexToColor(subject.color);

    return Dismissible(
      key: ValueKey(subject.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      background: const SizedBox(),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),

      // ================= CARD =================
      child: InkWell(
        onTap: onEdit, // ✅ CARD TAP = EDIT
        borderRadius: BorderRadius.circular(26),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, baseColor.withValues(alpha: 0.85)],
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- TITLE ----------
              Text(
                subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // ---------- DESCRIPTION ----------
              if (subject.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  subject.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // ---------- VIEW TASKS BUTTON ----------
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onViewTasks, // ✅ VIEW TASKS ONLY
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    fixedSize: Size(130, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                  label: const Text(
                    'View tasks',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
