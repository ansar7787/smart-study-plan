import 'package:flutter/material.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

typedef UserActionCallback = void Function(String userId, String action);

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final UserActionCallback? onAction;

  const UserTile({super.key, required this.user, this.onTap, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,

        // Avatar
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Name + Email
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          user.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Role badge
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            onAction?.call(user.id, value);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
