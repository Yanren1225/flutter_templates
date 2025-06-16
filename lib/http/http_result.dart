import 'package:fpdart/fpdart.dart';

class HttpError {
  final String message;
  final int? code;

  HttpError({required this.message, required this.code});

  @override
  String toString() => 'HttpError(code: $code, message: $message)';
}

class HttpResult<T> {
  final Either<HttpError, T> _value;

  HttpResult._(this._value);

  factory HttpResult.success(T value) => HttpResult._(Right(value));
  factory HttpResult.fail(HttpError error) => HttpResult._(Left(error));
  factory HttpResult.catchError(String message, {int? code}) =>
      HttpResult._(Left(HttpError(message: message, code: code)));

  Either<HttpError, T> toEither() => _value;

  B match<B>(B Function(HttpError error) error, B Function(T value) success) =>
      _value.match(error, success);

  T? get data => _value.getRight().toNullable();

  HttpError? get error => _value.getLeft().toNullable();

  static Future<HttpResult<List<T>>> joinAll<T>(
    List<Future<HttpResult<T>>> futures,
  ) async {
    final results = await Future.wait(futures);
    for (final result in results) {
      if (result.error != null) {
        return HttpResult.fail(result.error!);
      }
    }
    return HttpResult.success(results.map((r) => r.data as T).toList());
  }
}
