sealed class Result<S, E extends Object> {
  const Result();
  S unwrap() {
    return switch (this) {
      Success(value: final value) => value,
      Failure(exception: final e) => throw e,
    };
  }
}

final class Success<S, E extends Object> extends Result<S, E> {
  const Success(this.value);
  final S value;
}

final class Failure<S, E extends Object> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;
}
