import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/core/utils/logger.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_admin_stats.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminStatsUseCase getAdminStatsUseCase;

  AdminDashboardBloc({required this.getAdminStatsUseCase})
    : super(const AdminDashboardState()) {
    on<LoadAdminDashboardEvent>(_onLoadDashboard);
    on<RefreshAdminDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(state.copyWith(status: AdminDashboardStatus.loading));

    final result = await getAdminStatsUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.e('Admin dashboard load failed: ${failure.message}');
        emit(
          state.copyWith(
            status: AdminDashboardStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (stats) {
        emit(
          state.copyWith(status: AdminDashboardStatus.success, stats: stats),
        );
      },
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshAdminDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    add(const LoadAdminDashboardEvent());
  }
}
