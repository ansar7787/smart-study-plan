import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/di/service_locator.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/widgets/filter_button.dart';

import '../bloc/admin_users/admin_users_bloc.dart';
import '../widgets/user_tile.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUsersBloc>(
      create: (_) => getIt<AdminUsersBloc>()..add(const FetchUsersEvent()),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();

  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
  String _selectedFilter = 'all';

  void _handleSearch(String query) {
    if (query.isEmpty) {
      context.read<AdminUsersBloc>().add(const FetchUsersEvent());
    } else {
      context.read<AdminUsersBloc>().add(SearchUsersEvent(query));
    }
  }

  void _handleFilter(String role) {
    setState(() {
      _selectedFilter = role;
    });
    if (role == 'all') {
      context.read<AdminUsersBloc>().add(const FetchUsersEvent());
    } else {
      context.read<AdminUsersBloc>().add(FetchUsersByRoleEvent(role));
    }
  }

  void _handleUserAction(String userId, String action) {
    if (action == 'delete') {
      _showDeleteConfirmation(userId);
    } else if (action == 'view') {
      // TODO: Implement user details page
    }
  }

  void _showDeleteConfirmation(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminUsersBloc>().add(DeleteUserEvent(userId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<AdminUsersBloc>().add(const RefreshUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), elevation: 0),
      body: BlocListener<AdminUsersBloc, AdminUsersState>(
        listener: (context, state) {
          if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            SearchFilterBar(
              onSearch: _handleSearch,
              onFilter: _handleFilter,
              selectedFilter: _selectedFilter,
            ),
            Expanded(
              child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                builder: (context, state) {
                  if (state is UsersInitial || state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UsersError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AdminUsersBloc>().add(
                                const FetchUsersEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UsersLoaded) {
                    final users = state.users;

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return UserTile(
                            user: user,
                            onAction: _handleUserAction,
                            onTap: () {
                              // TODO: Open details page
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
