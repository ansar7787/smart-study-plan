part of 'admin_users_bloc.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends AdminUsersState {
  const UsersInitial();
}

class UsersLoading extends AdminUsersState {
  const UsersLoading();
}

class UsersLoaded extends AdminUsersState {
  final List<User> users;
  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersError extends AdminUsersState {
  final String message;
  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}
