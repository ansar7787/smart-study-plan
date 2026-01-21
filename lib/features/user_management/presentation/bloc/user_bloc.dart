// ignore_for_file: invalid_use_of_visible_for_testing_member, undefined_constructor_in_object_creation

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
  }) : super(const UserState()) {
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
    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Creating account...',
      ),
    );

    final result = await registerUserUseCase(
      RegisterUserParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: UserStatus.authenticated, user: user)),
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Logging in...',
      ),
    );

    final result = await loginUserUseCase(
      LoginUserParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: UserStatus.authenticated, user: user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<UserState> emit) async {
    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Logging out...',
      ),
    );

    final result = await logoutUserUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Logout failed: ${failure.message}');
        emit(
          state.copyWith(
            status: UserStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        AppLogger.d('Logout successful');
        emit(const UserState(status: UserStatus.unauthenticated));
      },
    );
  }

  /* ───────────────── AUTH STATE ───────────────── */

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<UserState> emit,
  ) async {
    // Keep internal loading silent or show initial splash
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (_) => emit(state.copyWith(status: UserStatus.unauthenticated)),
      (user) async {
        if (user == null) {
          emit(state.copyWith(status: UserStatus.unauthenticated));
        } else {
          emit(state.copyWith(status: UserStatus.authenticated, user: user));
        }
      },
    );
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Loading user...',
      ),
    );

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) {
        if (user == null) {
          emit(state.copyWith(status: UserStatus.unauthenticated));
        } else {
          emit(state.copyWith(status: UserStatus.authenticated, user: user));
        }
      },
    );
  }

  /* ───────────────── PROFILE UPDATE ───────────────── */

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state.user == null) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'User not authenticated',
        ),
      );
      return;
    }

    final currentUser = state.user!;

    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Updating profile...',
      ),
    );

    final updatedUser = currentUser.copyWith(
      name: event.name,
      photoUrl: event.photoUrl,
      updatedAt: DateTime.now(),
    );

    final result = await updateUserUseCase(updatedUser);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: UserStatus.authenticated, user: user)),
    );
  }

  /* ───────────────── AVATAR UPLOAD ───────────────── */

  Future<void> _onUpdateUserAvatar(
    UpdateUserAvatarEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state.user == null) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'User not authenticated',
        ),
      );
      return;
    }

    final currentUser = state.user!;

    emit(
      state.copyWith(
        status: UserStatus.loading,
        loadingMessage: 'Uploading photo...',
      ),
    );

    final uploadResult = await uploadUserAvatarUseCase(
      userId: currentUser.id,
      file: event.file,
    );

    await uploadResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (url) async {
        final updatedUser = currentUser.copyWith(
          photoUrl: url,
          updatedAt: DateTime.now(),
        );

        final result = await updateUserUseCase(updatedUser);

        result.fold(
          (f) => emit(
            state.copyWith(status: UserStatus.failure, errorMessage: f.message),
          ),
          (user) => emit(
            state.copyWith(status: UserStatus.authenticated, user: user),
          ),
        );
      },
    );
  }
}
