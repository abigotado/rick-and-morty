import 'package:characters_domain/characters_domain.dart';

extension FailureMessage on Failure {
  String get message => switch (this) {
    NetworkFailure() => 'No connection. Check your network and try again.',
    ServerFailure(statusCode: 429) => 'Too many requests. Wait a moment and try again.',
    ServerFailure() => 'Something went wrong on the server. Try again.',
    NotFoundFailure() => 'This character could not be found.',
  };
}
