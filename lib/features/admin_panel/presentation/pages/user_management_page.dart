import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/di/service_locator.dart';

import '../bloc/admin_users/admin_users_bloc.dart';
import '../widgets/user_tile.dart';
import 'package:smart_study_plan/core/widgets/skeletons/list_item_skeleton.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminUsersBloc>()..add(const FetchUsersEvent()),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatelessWidget {
  const _UserManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: BlocBuilder<AdminUsersBloc, AdminUsersState>(
        builder: (context, state) {
          if (state.status == AdminUsersStatus.loading) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => const ListItemSkeleton(),
            );
          }

          if (state.status == AdminUsersStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }

          if (state.status == AdminUsersStatus.success) {
            if (state.users.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                return UserTile(
                  user: state.users[index],
                  onAction: (userId, action) {
                    if (action == 'delete') {
                      context.read<AdminUsersBloc>().add(
                        DeleteUserEvent(userId),
                      );
                    }
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
