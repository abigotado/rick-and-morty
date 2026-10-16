import 'package:characters_domain/characters_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';

void main() {
  group('FailureMessage', () {
    group('message', () {
      test('NetworkFailure → asks to check the connection', () {
        expect(
          const NetworkFailure().message,
          'No connection. Check your network and try again.',
        );
      });

      test('ServerFailure(429) → asks to wait before retrying', () {
        expect(
          const ServerFailure(429).message,
          'Too many requests. Wait a moment and try again.',
        );
      });

      test('ServerFailure(500) → generic server message', () {
        expect(
          const ServerFailure(500).message,
          'Something went wrong on the server. Try again.',
        );
      });

      test('ServerFailure without code → generic server message', () {
        expect(
          const ServerFailure().message,
          'Something went wrong on the server. Try again.',
        );
      });

      test('NotFoundFailure → character not found', () {
        expect(const NotFoundFailure().message, 'This character could not be found.');
      });
    });
  });
}
