import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/core/utils/logger.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/get_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/login_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/logout_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/register_user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;
  final GetUserUseCase getCurrentUserUseCase;
  final LogoutUserUseCase logoutUserUseCase;

  UserBloc({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUserUseCase,
  }) : super(const UserInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

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
        role: event.role,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('Registration failed: ${failure.message}');
        emit(UserError(failure.message));
      },
      (user) {
        AppLogger.d('Registration successful: ${user.email}');
        emit(UserAuthenticated(user));
      },
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
      (failure) {
        AppLogger.e('Login failed: ${failure.message}');
        emit(UserError(failure.message));
      },
      (user) {
        AppLogger.d('Login successful: ${user.email}');
        emit(UserAuthenticated(user));
      },
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

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Checking authentication...'));

    final result = await getCurrentUserUseCase('');

    result.fold(
      (failure) {
        AppLogger.d('User not authenticated');
        emit(const UserNotAuthenticated());
      },
      (user) {
        AppLogger.d('User is authenticated: ${user.email}');
        emit(UserAuthenticated(user));
      },
    );
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading(message: 'Loading user...'));

    final result = await getCurrentUserUseCase('');

    result.fold(
      (failure) {
        AppLogger.e('Failed to get user: ${failure.message}');
        emit(UserError(failure.message));
      },
      (user) {
        emit(UserAuthenticated(user));
      },
    );
  }

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

    final updatedUser = User(
      id: currentUser.id,
      email: currentUser.email,
      name: event.name ?? currentUser.name,
      role: currentUser.role,
      photoUrl: event.photoUrl ?? currentUser.photoUrl,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
    );

    // For now, just emit updated state
    emit(
      UserUpdated(user: updatedUser, message: 'Profile updated successfully'),
    );
  }
}
