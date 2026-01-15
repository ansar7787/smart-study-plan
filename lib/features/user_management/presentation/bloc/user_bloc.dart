import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/core/utils/logger.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/get_current_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/login_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/logout_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/register_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/update_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/upload_user_avatar.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUserUseCase logoutUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final UploadUserAvatarUseCase uploadUserAvatarUseCase;

  UserBloc({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUserUseCase,
    required this.updateUserUseCase,
    required this.uploadUserAvatarUseCase,
  }) : super(const UserInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<UpdateUserAvatarEvent>(_onUpdateUserAvatar);
  }

  /* ───────────────── AUTH ───────────────── */

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Creating account...'));

    final result = await registerUserUseCase(
      RegisterUserParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserAuthenticated(user)),
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Logging in...'));

    final result = await loginUserUseCase(
      LoginUserParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading(message: 'Logging out...'));

    final result = await logoutUserUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Logout failed: ${failure.message}');
        emit(UserError(failure.message));
      },
      (_) {
        AppLogger.d('Logout successful');
        emit(const UserLoggedOut());
      },
    );
  }

  /* ───────────────── AUTH STATE ───────────────── */

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Checking authentication...'));

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((_) => emit(const UserNotAuthenticated()), (user) {
      if (user == null) {
        emit(const UserNotAuthenticated());
      } else {
        emit(UserAuthenticated(user));
      }
    });
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Loading user...'));

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(UserError(failure.message)), (user) {
      if (user == null) {
        emit(const UserNotAuthenticated());
      } else {
        emit(UserAuthenticated(user));
      }
    });
  }

  /* ───────────────── PROFILE UPDATE ───────────────── */

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserAuthenticated) {
      emit(const UserError('User not authenticated'));
      return;
    }

    final currentUser = (state as UserAuthenticated).user;

    emit(const UserLoading(message: 'Updating profile...'));

    final updatedUser = currentUser.copyWith(
      name: event.name,
      photoUrl: event.photoUrl,
      updatedAt: DateTime.now(),
    );

    final result = await updateUserUseCase(updatedUser);

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserAuthenticated(user)),
    );
  }

  /* ───────────────── AVATAR UPLOAD ───────────────── */

  Future<void> _onUpdateUserAvatar(
    UpdateUserAvatarEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserAuthenticated) {
      emit(const UserError('User not authenticated'));
      return;
    }

    final currentUser = (state as UserAuthenticated).user;

    emit(const UserLoading(message: 'Uploading photo...'));

    final uploadResult = await uploadUserAvatarUseCase(
      userId: currentUser.id,
      file: event.file,
    );

    await uploadResult.fold(
      (failure) async => emit(UserError(failure.message)),
      (url) async {
        final updatedUser = currentUser.copyWith(
          photoUrl: url,
          updatedAt: DateTime.now(),
        );

        final result = await updateUserUseCase(updatedUser);

        result.fold(
          (f) => emit(UserError(f.message)),
          (user) => emit(UserAuthenticated(user)),
        );
      },
    );
  }
}
