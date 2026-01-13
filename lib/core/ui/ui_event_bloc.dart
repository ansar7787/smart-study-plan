import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui_event.dart';

class UiEventBloc extends Cubit<UiEvent?> {
  UiEventBloc() : super(null);

  void emitEvent(UiEvent event) => emit(event);

  void clear() => emit(null);
}
