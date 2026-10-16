import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/network/create_dio.dart';
import 'package:rick_and_morty/features/characters/data/characters_api.dart';

import '../../helpers/character_fixtures.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  group('createDio', () {
    test('requests → hit the public api with timeouts set', () async {
      final adapter = FakeAdapter(status: 200, body: jsonEncode(pageJson()));
      final dio = createDio()..httpClientAdapter = adapter;

      await CharactersApi(dio).fetchCharacters(page: 1);

      expect(
        adapter.requests.single.uri.toString(),
        'https://rickandmortyapi.com/api/character/?page=1',
      );
      expect(dio.options.connectTimeout, isNotNull);
      expect(dio.options.receiveTimeout, isNotNull);
    });
  });
}
