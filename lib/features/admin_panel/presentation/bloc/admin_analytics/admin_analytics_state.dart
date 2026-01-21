part of 'admin_analytics_bloc.dart';

enum AdminAnalyticsStatus { initial, loading, success, failure }

class AdminAnalyticsState extends Equatable {
  final AdminAnalyticsStatus status;
  final List<UserProgress> usersProgress;
  final String? errorMessage;

  const AdminAnalyticsState({
    this.status = AdminAnalyticsStatus.initial,
    this.usersProgress = const [],
    this.errorMessage,
  });

  AdminAnalyticsState copyWith({
    AdminAnalyticsStatus? status,
    List<UserProgress>? usersProgress,
    String? errorMessage,
  }) {
    return AdminAnalyticsState(
      status: status ?? this.status,
      usersProgress: usersProgress ?? this.usersProgress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, usersProgress, errorMessage];
}
