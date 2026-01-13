import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_overview.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsOverview overview;

  const AnalyticsLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

class AnalyticsActionSuccess extends AnalyticsState {}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
