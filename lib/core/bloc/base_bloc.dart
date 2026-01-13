import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/core/errors/failure_mapper.dart';
import 'base_event.dart';
import 'base_state.dart';
import 'view_state.dart';
import '../error/failures.dart';

abstract class BaseBloc<E extends BaseEvent, T> extends Bloc<E, BaseState<T>> {
  BaseBloc(super.initialState);

  void emitLoading(Emitter<BaseState<T>> emit) {
    emit(BaseState(viewState: const ViewLoading()));
  }

  void emitSuccess(Emitter<BaseState<T>> emit, T data) {
    emit(BaseState(viewState: ViewSuccess<T>(data)));
  }

  void emitFailure(Emitter<BaseState<T>> emit, Failure failure) {
    emit(BaseState(viewState: ViewFailure(FailureMapper.map(failure))));
  }
}
