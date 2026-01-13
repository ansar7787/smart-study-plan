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

  const RegisterUserEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
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

class ResetPasswordEvent extends UserEvent {
  final String email;
  const ResetPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}
