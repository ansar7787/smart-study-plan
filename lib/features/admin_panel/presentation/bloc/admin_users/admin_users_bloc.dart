import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/core/utils/logger.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/delete_user_admin.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_all_users.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

part 'admin_users_event.dart';
part 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final DeleteUserAdminUseCase deleteUserAdminUseCase;

  AdminUsersBloc({
    required this.getAllUsersUseCase,
    required this.deleteUserAdminUseCase,
  }) : super(const UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<FetchUsersByRoleEvent>(_onFetchUsersByRole);
    on<SearchUsersEvent>(_onSearchUsers);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(const UsersLoading());

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Fetch users failed: ${failure.message}');
        emit(UsersError(failure.message));
      },
      (users) {
        emit(UsersLoaded(users));
      },
    );
  }

  Future<void> _onRefreshUsers(
    RefreshUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    add(const FetchUsersEvent());
  }

  Future<void> _onFetchUsersByRole(
    FetchUsersByRoleEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(const UsersLoading());

    final result = await getAllUsersUseCase(const NoParams());

    result.fold((failure) => emit(UsersError(failure.message)), (users) {
      final filtered = users.where((u) => u.role == event.role).toList();
      emit(UsersLoaded(filtered));
    });
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await getAllUsersUseCase(const NoParams());

    result.fold((failure) => emit(UsersError(failure.message)), (users) {
      final query = event.query.toLowerCase();
      final filtered = users.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
      emit(UsersLoaded(filtered));
    });
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    final currentState = state;
    emit(const UsersLoading());

    final result = await deleteUserAdminUseCase(
      DeleteUserParams(userId: event.userId),
    );

    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      if (currentState is UsersLoaded) {
        final updated = currentState.users
            .where((u) => u.id != event.userId)
            .toList();
        emit(UsersLoaded(updated));
      } else {
        add(const FetchUsersEvent());
      }
    });
  }
}
