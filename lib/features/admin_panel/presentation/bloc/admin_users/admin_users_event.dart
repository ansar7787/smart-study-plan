part of 'admin_users_bloc.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends AdminUsersEvent {
  const FetchUsersEvent();
}

class FetchUsersByRoleEvent extends AdminUsersEvent {
  final String role;
  const FetchUsersByRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

class SearchUsersEvent extends AdminUsersEvent {
  final String query;
  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteUserEvent extends AdminUsersEvent {
  final String userId;
  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshUsersEvent extends AdminUsersEvent {
  const RefreshUsersEvent();
}
