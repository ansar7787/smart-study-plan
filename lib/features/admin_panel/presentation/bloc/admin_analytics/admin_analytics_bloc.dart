import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/admin_panel/domain/entities/user_progress.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_all_user_progress.dart';

part 'admin_analytics_event.dart';
part 'admin_analytics_state.dart';

class AdminAnalyticsBloc
    extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final GetAllUserProgressUseCase getAllUserProgressUseCase;

  AdminAnalyticsBloc({required this.getAllUserProgressUseCase})
    : super(const AdminAnalyticsInitial()) {
    on<LoadAllUserProgressEvent>(_onLoadAllProgress);
    on<RefreshUserProgressEvent>(_onRefreshProgress);
  }

  Future<void> _onLoadAllProgress(
    LoadAllUserProgressEvent event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(const AdminAnalyticsLoading());

    final result = await getAllUserProgressUseCase(const NoParams());

    result.fold(
      (failure) => emit(AdminAnalyticsError(failure.message)),
      (progress) => emit(AllUserProgressLoaded(progress)),
    );
  }

  Future<void> _onRefreshProgress(
    RefreshUserProgressEvent event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    add(const LoadAllUserProgressEvent());
  }
}
