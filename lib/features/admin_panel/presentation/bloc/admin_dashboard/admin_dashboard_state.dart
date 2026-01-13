part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Loaded successfully
class AdminDashboardLoaded extends AdminDashboardState {
  final AdminStats stats;

  const AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
