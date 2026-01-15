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
  final String? name;
  final String? photoUrl;

  const UpdateUserEvent({this.name, this.photoUrl});

  @override
  List<Object?> get props => [name, photoUrl];
}

class UpdateUserAvatarEvent extends UserEvent {
  final File file;

  const UpdateUserAvatarEvent(this.file);

  @override
  List<Object?> get props => [file];
}
