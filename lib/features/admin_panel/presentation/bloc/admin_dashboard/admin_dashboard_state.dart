part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends AdminDashboardState {
  const DashboardInitial();
}

class DashboardLoading extends AdminDashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends AdminDashboardState {
  final AdminStats stats;
  const DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DashboardError extends AdminDashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
