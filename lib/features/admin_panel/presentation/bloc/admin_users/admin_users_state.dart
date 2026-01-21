part of 'admin_users_bloc.dart';

enum AdminUsersStatus { initial, loading, success, failure }

class AdminUsersState extends Equatable {
  final AdminUsersStatus status;
  final List<User> users;
  final String? errorMessage;

  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<User>? users,
    String? errorMessage,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
