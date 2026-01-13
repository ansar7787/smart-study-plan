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
  }) : super(AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<CreateStudyGoalEvent>(_onCreateGoal);
    on<UpdateStudyGoalEvent>(_onUpdateGoal);
    on<DeleteStudyGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    final result = await loadOverview(
      LoadAnalyticsOverviewParams(
        userId: event.userId,
        start: event.start,
        end: event.end,
      ),
    );

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (overview) => emit(AnalyticsLoaded(overview)),
    );
  }

  Future<void> _onCreateGoal(
    CreateStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await createGoal(
      CreateStudyGoalParams(
        userId: event.userId,
        title: event.title,
        description: event.description,
        metricType: event.metricType, // ✅ FIXED
        targetValue: event.targetValue,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (_) => emit(AnalyticsActionSuccess()),
    );
  }

  Future<void> _onUpdateGoal(
    UpdateStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await updateGoal(event.goal); // ✅ FIXED

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (_) => emit(AnalyticsActionSuccess()),
    );
  }

  Future<void> _onDeleteGoal(
    DeleteStudyGoalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await deleteGoal(event.goalId);

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (_) => emit(AnalyticsActionSuccess()),
    );
  }
}
