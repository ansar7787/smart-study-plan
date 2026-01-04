import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/widgets/filter_button.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/user_tile.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const FetchAllUsersEvent());
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      context.read<AdminBloc>().add(const FetchAllUsersEvent());
    } else {
      context.read<AdminBloc>().add(SearchUsersEvent(query));
    }
  }

  void _handleFilter(String role) {
    setState(() {
      _selectedFilter = role;
    });
    if (role == 'all') {
      context.read<AdminBloc>().add(const FetchAllUsersEvent());
    } else {
      context.read<AdminBloc>().add(FetchUsersByRoleEvent(role));
    }
  }

  void _handleUserAction(String userId, String action) {
    if (action == 'delete') {
      _showDeleteConfirmation(userId);
    } else if (action == 'view') {
      // Show user details
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
              context.read<AdminBloc>().add(DeleteUserEvent(userId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), elevation: 0),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminUserDeleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminError) {
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
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminError) {
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
                              context.read<AdminBloc>().add(
                                const FetchAllUsersEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AdminUsersLoaded) {
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
                      onRefresh: () async {
                        context.read<AdminBloc>().add(
                          const FetchAllUsersEvent(),
                        );
                      },
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return UserTile(
                            user: user,
                            onAction: _handleUserAction,
                            onTap: () {
                              // Show user details
                            },
                          );
                        },
                      ),
                    );
                  }

                  if (state is AdminDataLoaded) {
                    final users = state.users;

                    if (users.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return UserTile(
                          user: user,
                          onAction: _handleUserAction,
                        );
                      },
                    );
                  }

                  return const Center(child: Text('No data'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
