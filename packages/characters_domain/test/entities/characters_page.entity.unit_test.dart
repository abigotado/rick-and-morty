import 'package:characters_domain/characters_domain.dart';
import 'package:test/test.dart';

void main() {
  group('CharactersPageEntity', () {
    group('==', () {
      test('different nextPage → not equal', () {
        expect(
          const CharactersPageEntity(characters: [], nextPage: 2),
          isNot(const CharactersPageEntity(characters: [], nextPage: 3)),
        );
      });
    });
  });
}
