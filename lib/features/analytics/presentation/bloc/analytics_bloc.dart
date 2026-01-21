import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/load_analytics_overview_usecase.dart';
import '../../domain/usecases/create_study_goal_usecase.dart';
import '../../domain/usecases/update_study_goal_usecase.dart';
import '../../domain/usecases/delete_study_goal_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final LoadAnalyticsOverviewUseCase loadOverview;
  final CreateStudyGoalUseCase createGoal;
  final UpdateStudyGoalUseCase updateGoal;
  final DeleteStudyGoalUseCase deleteGoal;

  AnalyticsBloc({
    required this.loadOverview,
    required this.createGoal,
    required this.updateGoal,
    required this.deleteGoal,
  }) : super(const AnalyticsState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<CreateStudyGoalEvent>(_onCreateGoal);
    on<UpdateStudyGoalEvent>(_onUpdateGoal);
    on<DeleteStudyGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final result = await loadOverview(
      LoadAnalyticsOverviewParams(
        userId: event.userId,
        start: event.start,
        end: event.end,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (overview) => emit(
        state.copyWith(status: AnalyticsStatus.success, overview: overview),
      ),
    );
  }

  Future<void> _onCreateGoal(
    CreateStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final result = await createGoal(
      CreateStudyGoalParams(
        userId: event.userId,
        title: event.title,
        description: event.description,
        metricType: event.metricType,
        targetValue: event.targetValue,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadAnalyticsEvent(userId: event.userId)), // Reload
    );
  }

  Future<void> _onUpdateGoal(
    UpdateStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final result = await updateGoal(event.goal);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => add(LoadAnalyticsEvent(userId: event.goal.userId)), // Reload
    );
  }

  Future<void> _onDeleteGoal(
    DeleteStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Optimistic/Loading
    emit(state.copyWith(status: AnalyticsStatus.loading));

    // Note: To implement optimistic delete, we'd need to manually remove from overview.activeGoals logic here.
    // For now, reload is acceptable for MVP compliance or I can make it optimistic if I parse overview.

    final result = await deleteGoal(event.goalId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        add(LoadAnalyticsEvent(userId: event.userId));
      },
    );
  }
}
