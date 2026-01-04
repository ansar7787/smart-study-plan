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
    : super(const DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await getAdminStatsUseCase(const NoParams());
    result.fold(
      (failure) {
        AppLogger.e('Failed to load dashboard: ${failure.message}');
        emit(DashboardError(failure.message));
      },
      (stats) {
        AppLogger.d('Dashboard stats loaded');
        emit(DashboardLoaded(stats));
      },
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    add(const LoadDashboardEvent());
  }
}
