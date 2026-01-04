import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/core/utils/logger.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/delete_user_admin.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_all_users.dart';
import 'package:smart_study_plan/features/user_management/domain/entities/user.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetAdminStatsUseCase getAdminStatsUseCase;
  final DeleteUserAdminUseCase deleteUserAdminUseCase;

  AdminBloc({
    required this.getAllUsersUseCase,
    required this.getAdminStatsUseCase,
    required this.deleteUserAdminUseCase,
  }) : super(const AdminInitial()) {
    on<FetchAllUsersEvent>(_onFetchAllUsers);
    on<FetchAdminStatsEvent>(_onFetchAdminStats);
    on<DeleteUserEvent>(_onDeleteUser);
    on<RefreshAdminDataEvent>(_onRefreshAdminData);
    on<SearchUsersEvent>(_onSearchUsers);
    on<FetchUsersByRoleEvent>(_onFetchUsersByRole);
  }

  Future<void> _onFetchAllUsers(
    FetchAllUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading(message: 'Loading users...'));

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Failed to fetch users: ${failure.message}');
        emit(AdminError(failure.message));
      },
      (users) {
        AppLogger.d('Fetched ${users.length} users');
        emit(AdminUsersLoaded(users));
      },
    );
  }

  Future<void> _onFetchAdminStats(
    FetchAdminStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading(message: 'Loading statistics...'));

    final result = await getAdminStatsUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Failed to fetch stats: ${failure.message}');
        emit(AdminError(failure.message));
      },
      (stats) {
        AppLogger.d('Fetched admin stats');
        emit(AdminStatsLoaded(stats));
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading(message: 'Deleting user...'));

    final result = await deleteUserAdminUseCase(
      DeleteUserParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        AppLogger.e('Failed to delete user: ${failure.message}');
        emit(AdminError(failure.message));
      },
      (_) {
        AppLogger.d('User deleted: ${event.userId}');
        // Refresh user list after deletion
        add(const FetchAllUsersEvent());
        emit(
          AdminUserDeleted(
            userId: event.userId,
            message: 'User deleted successfully',
          ),
        );
      },
    );
  }

  Future<void> _onRefreshAdminData(
    RefreshAdminDataEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading(message: 'Refreshing data...'));

    final usersResult = await getAllUsersUseCase(const NoParams());
    final statsResult = await getAdminStatsUseCase(const NoParams());

    // Combine results
    usersResult.fold(
      (failure) {
        AppLogger.e('Failed to refresh data: ${failure.message}');
        emit(AdminError(failure.message));
      },
      (users) {
        statsResult.fold(
          (failure) {
            AppLogger.e('Failed to load stats: ${failure.message}');
            emit(AdminUsersLoaded(users));
          },
          (stats) {
            emit(AdminDataLoaded(users: users, stats: stats));
          },
        );
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const FetchAllUsersEvent());
      return;
    }

    emit(const AdminLoading(message: 'Searching...'));

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(AdminError(failure.message));
      },
      (allUsers) {
        // Local search
        final filtered = allUsers
            .where(
              (user) =>
                  user.name.toLowerCase().contains(event.query.toLowerCase()) ||
                  user.email.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();

        emit(AdminUsersLoaded(filtered));
      },
    );
  }

  Future<void> _onFetchUsersByRole(
    FetchUsersByRoleEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading(message: 'Loading users by role...'));

    final result = await getAllUsersUseCase(const NoParams());
    // If you have a separate usecase for role, use that; otherwise filter here

    result.fold((failure) => emit(AdminError(failure.message)), (users) {
      final filtered = users
          .where((u) => u.role.toLowerCase() == event.role.toLowerCase())
          .toList();
      emit(AdminUsersLoaded(filtered));
    });
  }
}
