import 'package:characters_domain/characters_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';

void main() {
  group('FailureMessage', () {
    group('title', () {
      test('NetworkFailure → lost connection', () {
        expect(const NetworkFailure().title, 'Lost connection to the multiverse');
      });

      test('ServerFailure(429) → too many requests', () {
        expect(const ServerFailure(429).title, 'Too many requests');
      });

      test('ServerFailure(500) → server not responding', () {
        expect(const ServerFailure(500).title, 'The server is not responding');
      });

      test('ServerFailure without code → server not responding', () {
        expect(const ServerFailure().title, 'The server is not responding');
      });

      test('NotFoundFailure → character not found', () {
        expect(const NotFoundFailure().title, 'Character not found');
      });
    });

    group('message', () {
      test('NetworkFailure → asks to check the connection', () {
        expect(
          const NetworkFailure().message,
          'Check your internet connection and try again.',
        );
      });

      test('ServerFailure(429) → asks to wait before retrying', () {
        expect(const ServerFailure(429).message, 'Wait a moment and try again.');
      });

      test('ServerFailure(500) → generic server message', () {
        expect(
          const ServerFailure(500).message,
          'Something went wrong on its side. Try again in a moment.',
        );
      });

      test('ServerFailure without code → generic server message', () {
        expect(
          const ServerFailure().message,
          'Something went wrong on its side. Try again in a moment.',
        );
      });

      test('NotFoundFailure → character could not be found', () {
        expect(const NotFoundFailure().message, 'This character could not be found.');
      });
    });
  });
}
