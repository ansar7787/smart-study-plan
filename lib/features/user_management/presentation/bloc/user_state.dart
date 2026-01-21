part of 'user_bloc.dart';

enum UserStatus { initial, loading, authenticated, unauthenticated, failure }

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final String? errorMessage;
  final String? loadingMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
    this.loadingMessage,
  });

  UserState copyWith({
    UserStatus? status,
    User? user,
    String? errorMessage,
    String? loadingMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, loadingMessage];
}
