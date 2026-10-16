import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';

void main() {
  group('CharactersState', () {
    group('canLoadMore', () {
      test('success with a next page and idle next page → true', () {
        const state = CharactersState(status: CharactersStatus.success, nextPage: 2);

        expect(state.canLoadMore, isTrue);
      });

      test('status loading → false', () {
        const state = CharactersState(status: CharactersStatus.loading, nextPage: 2);

        expect(state.canLoadMore, isFalse);
      });

      test('nextPage null → false', () {
        const state = CharactersState(status: CharactersStatus.success);

        expect(state.canLoadMore, isFalse);
      });

      test('next page loading → false', () {
        const state = CharactersState(
          status: CharactersStatus.success,
          nextPage: 2,
          nextPageStatus: NextPageStatus.loading,
        );

        expect(state.canLoadMore, isFalse);
      });
    });
  });
}
