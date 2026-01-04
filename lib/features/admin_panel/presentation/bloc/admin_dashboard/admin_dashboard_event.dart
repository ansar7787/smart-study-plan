part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends AdminDashboardEvent {
  const LoadDashboardEvent();
}

class RefreshDashboardEvent extends AdminDashboardEvent {
  const RefreshDashboardEvent();
}
