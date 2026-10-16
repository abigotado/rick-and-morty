import 'package:characters_domain/characters_domain.dart';
import 'package:test/test.dart';

void main() {
  group('CharactersPageEntity', () {
    group('==', () {
      test('different nextPage → not equal', () {
        expect(
          const CharactersPageEntity(characters: [], totalCount: 1, nextPage: 2),
          isNot(const CharactersPageEntity(characters: [], totalCount: 1, nextPage: 3)),
        );
      });

      test('different totalCount → not equal', () {
        expect(
          const CharactersPageEntity(characters: [], totalCount: 1),
          isNot(const CharactersPageEntity(characters: [], totalCount: 2)),
        );
      });
    });
  });
}
