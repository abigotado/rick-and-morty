import 'package:characters_domain/characters_domain.dart';

extension FailureMessage on Failure {
  String get title => switch (this) {
    NetworkFailure() => 'Lost connection to the multiverse',
    ServerFailure(statusCode: 429) => 'Too many requests',
    ServerFailure() => 'The server is not responding',
    NotFoundFailure() => 'Character not found',
  };

  String get message => switch (this) {
    NetworkFailure() => 'Check your internet connection and try again.',
    ServerFailure(statusCode: 429) => 'Wait a moment and try again.',
    ServerFailure() => 'Something went wrong on its side. Try again in a moment.',
    NotFoundFailure() => 'This character could not be found.',
  };
}
