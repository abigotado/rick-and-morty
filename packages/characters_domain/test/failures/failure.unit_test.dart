import 'package:characters_domain/characters_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    group('==', () {
      test('ServerFailure with the same code → equal', () {
        expect(const ServerFailure(500), const ServerFailure(500));
      });

      test('ServerFailure with a different code → not equal', () {
        expect(const ServerFailure(500), isNot(const ServerFailure(429)));
        expect(const ServerFailure(500), isNot(const ServerFailure()));
      });

      test('different failure types → not equal', () {
        expect(const NetworkFailure(), isNot(const NotFoundFailure()));
      });
    });
  });
}
