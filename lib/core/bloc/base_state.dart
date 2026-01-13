import 'package:equatable/equatable.dart';
import 'view_state.dart';

class BaseState<T> extends Equatable {
  final ViewState<T> viewState;

  const BaseState({required this.viewState});

  factory BaseState.initial() {
    return BaseState<T>(viewState: const ViewInitial());
  }

  factory BaseState.loading() {
    return BaseState<T>(viewState: const ViewLoading());
  }

  factory BaseState.loadingWithProgress(double progress) {
    return BaseState<T>(viewState: ViewLoading(progress: progress));
  }

  factory BaseState.success(T data) {
    return BaseState<T>(viewState: ViewSuccess<T>(data));
  }

  factory BaseState.failure(String message) {
    return BaseState<T>(viewState: ViewFailure<T>(message));
  }

  @override
  List<Object?> get props => [viewState];
}
