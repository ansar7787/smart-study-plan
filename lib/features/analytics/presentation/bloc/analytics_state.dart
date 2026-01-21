import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_overview.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final AnalyticsOverview? overview;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.overview,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsOverview? overview,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage];
}
