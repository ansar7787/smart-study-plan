part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  final String? message;

  const UserLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class UserAuthenticated extends UserState {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;
  final String? code;

  const UserError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class UserNotAuthenticated extends UserState {
  const UserNotAuthenticated();
}

class UserLoggedOut extends UserState {
  const UserLoggedOut();
}

class UserUpdated extends UserState {
  final User user;
  final String message;

  const UserUpdated({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}
