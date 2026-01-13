sealed class UiEvent {
  const UiEvent();
}

class ShowSnackbar extends UiEvent {
  final String message;
  const ShowSnackbar(this.message);
}

class ShowDialogEvent extends UiEvent {
  final String title;
  final String message;
  const ShowDialogEvent(this.title, this.message);
}

class NavigateEvent extends UiEvent {
  final String route;
  final Object? extra;
  const NavigateEvent(this.route, {this.extra});
}
