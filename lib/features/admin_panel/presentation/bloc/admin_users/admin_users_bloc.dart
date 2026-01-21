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
  }) : super(const AdminUsersState()) {
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
    emit(state.copyWith(status: AdminUsersStatus.loading));

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Fetch users failed: ${failure.message}');
        emit(
          state.copyWith(
            status: AdminUsersStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (users) {
        emit(state.copyWith(status: AdminUsersStatus.success, users: users));
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
    emit(state.copyWith(status: AdminUsersStatus.loading));

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (users) {
        final filtered = users.where((u) => u.role == event.role).toList();
        emit(state.copyWith(status: AdminUsersStatus.success, users: filtered));
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    // If we already have users loaded, filter locally first?
    // Ideally we might want to re-fetch if we suspect stale data, but local filter is faster.
    // However, the original implementation fetched fresh every time. Let's optimize if possible,
    // but sticking to fetching fresh for consistency with original logic, or better:
    // Actually, searching should probably just filter the already loaded users if they are there?
    // But original code called `getAllUsersUseCase`. I'll stick to that to be safe.

    emit(state.copyWith(status: AdminUsersStatus.loading));

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (users) {
        final query = event.query.toLowerCase();
        final filtered = users.where((u) {
          return u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query);
        }).toList();
        emit(state.copyWith(status: AdminUsersStatus.success, users: filtered));
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    // Optimistic Update
    final previousUsers = state.users;
    final updatedUsers = previousUsers
        .where((u) => u.id != event.userId)
        .toList();
    emit(state.copyWith(users: updatedUsers));

    final result = await deleteUserAdminUseCase(
      DeleteUserParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        // Revert
        emit(
          state.copyWith(
            status: AdminUsersStatus.failure,
            errorMessage: failure.message,
            users: previousUsers,
          ),
        );
      },
      (_) {
        // Success confirm
        emit(state.copyWith(status: AdminUsersStatus.success));
      },
    );
  }
}
