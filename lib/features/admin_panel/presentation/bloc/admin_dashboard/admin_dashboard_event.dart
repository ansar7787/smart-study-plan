part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load
class LoadAdminDashboardEvent extends AdminDashboardEvent {
  const LoadAdminDashboardEvent();
}

/// Manual refresh (pull-to-refresh / retry)
class RefreshAdminDashboardEvent extends AdminDashboardEvent {
  const RefreshAdminDashboardEvent();
}
