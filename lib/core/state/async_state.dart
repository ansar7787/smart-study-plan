class AsyncState<T> {
  final bool isLoading;
  final T? data;
  final String? error;

  const AsyncState({this.isLoading = false, this.data, this.error});

  AsyncState<T> copyWith({bool? isLoading, T? data, String? error}) {
    return AsyncState<T>(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }

  factory AsyncState.initial() => const AsyncState();
}
