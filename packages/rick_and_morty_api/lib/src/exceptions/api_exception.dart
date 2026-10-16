sealed class ApiException implements Exception {
  const ApiException();
}

final class ApiConnectionException extends ApiException {
  const ApiConnectionException();
}

final class ApiResponseException extends ApiException {
  const ApiResponseException(this.statusCode);

  final int? statusCode;
}

final class ApiFormatException extends ApiException {
  const ApiFormatException(this.cause);

  final Object cause;
}
