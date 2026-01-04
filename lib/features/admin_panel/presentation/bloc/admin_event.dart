part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllUsersEvent extends AdminEvent {
  const FetchAllUsersEvent();
}

class FetchUsersByRoleEvent extends AdminEvent {
  final String role;

  const FetchUsersByRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

class FetchAdminStatsEvent extends AdminEvent {
  const FetchAdminStatsEvent();
}

class DeleteUserEvent extends AdminEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserRoleEvent extends AdminEvent {
  final String userId;
  final String newRole;

  const UpdateUserRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}

class SearchUsersEvent extends AdminEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshAdminDataEvent extends AdminEvent {
  const RefreshAdminDataEvent();
}
