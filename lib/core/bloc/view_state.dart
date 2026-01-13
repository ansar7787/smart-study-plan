import 'package:equatable/equatable.dart';

abstract class ViewState<T> extends Equatable {
  const ViewState();

  @override
  List<Object?> get props => [];
}

/// INITIAL
class ViewInitial<T> extends ViewState<T> {
  const ViewInitial();
}

/// LOADING (✅ supports progress)
class ViewLoading<T> extends ViewState<T> {
  final double? progress; // 0.0 → 1.0

  const ViewLoading({this.progress});

  @override
  List<Object?> get props => [progress];
}

/// SUCCESS
class ViewSuccess<T> extends ViewState<T> {
  final T data;

  const ViewSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

/// FAILURE (✅ supports message)
class ViewFailure<T> extends ViewState<T> {
  final String message;

  const ViewFailure(this.message);

  @override
  List<Object?> get props => [message];
}
