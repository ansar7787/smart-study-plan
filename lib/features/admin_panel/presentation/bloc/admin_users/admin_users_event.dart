part of 'admin_users_bloc.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

/// Load all users
class FetchUsersEvent extends AdminUsersEvent {
  const FetchUsersEvent();
}

/// Refresh list
class RefreshUsersEvent extends AdminUsersEvent {
  const RefreshUsersEvent();
}

/// Filter by role (admin / student)
class FetchUsersByRoleEvent extends AdminUsersEvent {
  final UserRole role;

  const FetchUsersByRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

/// Search users
class SearchUsersEvent extends AdminUsersEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Delete user
class DeleteUserEvent extends AdminUsersEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
