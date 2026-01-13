import '../error/failures.dart';

class FailureMapper {
  static String map(Failure failure) {
    return switch (failure) {
      NetworkFailure _ => 'No internet connection',
      CacheFailure _ => 'Local storage error',
      ServerFailure f => f.message,
      _ => 'Something went wrong',
    };
  }
}
