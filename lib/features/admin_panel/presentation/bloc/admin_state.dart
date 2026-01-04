part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  final String? message;

  const AdminLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AdminUsersLoaded extends AdminState {
  final List<User> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminStatsLoaded extends AdminState {
  final AdminStats stats;

  const AdminStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminDataLoaded extends AdminState {
  final List<User> users;
  final AdminStats stats;

  const AdminDataLoaded({required this.users, required this.stats});

  @override
  List<Object?> get props => [users, stats];
}

class AdminUserDeleted extends AdminState {
  final String userId;
  final String message;

  const AdminUserDeleted({required this.userId, required this.message});

  @override
  List<Object?> get props => [userId, message];
}

class AdminError extends AdminState {
  final String message;
  final String? code;

  const AdminError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
