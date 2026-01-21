import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SharedPreferences _prefs;
  static const String _kOnboardingCompletedKey = 'onboarding_completed';

  OnboardingBloc(this._prefs) : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckStatus);
    on<CompleteOnboarding>(_onComplete);
  }

  void _onCheckStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) {
    final completed = _prefs.getBool(_kOnboardingCompletedKey) ?? false;
    if (completed) {
      emit(OnboardingCompleted());
    } else {
      emit(OnboardingRequired());
    }
  }

  Future<void> _onComplete(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await _prefs.setBool(_kOnboardingCompletedKey, true);
    emit(OnboardingCompleted());
  }
}
