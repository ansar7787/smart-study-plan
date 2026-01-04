part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUserEvent extends UserEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterUserEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  const LoginUserEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends UserEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends UserEvent {
  const CheckAuthStatusEvent();
}

class GetCurrentUserEvent extends UserEvent {
  const GetCurrentUserEvent();
}

class UpdateUserEvent extends UserEvent {
  final String userId;
  final String? name;
  final String? photoUrl;

  const UpdateUserEvent({required this.userId, this.name, this.photoUrl});

  @override
  List<Object?> get props => [userId, name, photoUrl];
}
