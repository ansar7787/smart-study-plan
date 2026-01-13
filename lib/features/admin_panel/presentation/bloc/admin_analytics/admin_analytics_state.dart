part of 'admin_analytics_bloc.dart';

abstract class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState();

  @override
  List<Object?> get props => [];
}

class AdminAnalyticsInitial extends AdminAnalyticsState {
  const AdminAnalyticsInitial();
}

class AdminAnalyticsLoading extends AdminAnalyticsState {
  const AdminAnalyticsLoading();
}

class AllUserProgressLoaded extends AdminAnalyticsState {
  final List<UserProgress> usersProgress;

  const AllUserProgressLoaded(this.usersProgress);

  @override
  List<Object?> get props => [usersProgress];
}

class AdminAnalyticsError extends AdminAnalyticsState {
  final String message;

  const AdminAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
