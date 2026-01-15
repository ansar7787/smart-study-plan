import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/reset_password.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  ResetPasswordCubit(this.resetPasswordUseCase)
    : super(const ResetPasswordInitial());

  Future<void> sendResetLink(String email) async {
    emit(const ResetPasswordLoading());

    final result = await resetPasswordUseCase(email);

    result.fold(
      (failure) => emit(ResetPasswordFailure(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
