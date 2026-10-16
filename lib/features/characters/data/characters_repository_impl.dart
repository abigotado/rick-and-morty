import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/failure.dart';
import 'package:rick_and_morty/features/characters/data/character_mapper.dart';
import 'package:rick_and_morty/features/characters/data/characters_api.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';

class CharactersRepositoryImpl implements CharactersRepository {
  const CharactersRepositoryImpl(this._api);

  final CharactersApi _api;

  @override
  Future<CharactersPage> getCharacters({int page = 1, String name = ''}) => _guard(
    () async => CharacterMapper.pageFromJson(await _api.fetchCharacters(page: page, name: name)),
    onNotFound: () => const CharactersPage.empty(),
  );

  @override
  Future<Character> getCharacter(int id) => _guard(
    () async => CharacterMapper.fromJson(await _api.fetchCharacter(id)),
  );

  Future<T> _guard<T>(
    Future<T> Function() request, {
    T Function()? onNotFound,
  }) async {
    try {
      return await request();
    } on DioException catch (e, s) {
      if (e.response?.statusCode == 404) {
        if (onNotFound != null) return onNotFound();
        Error.throwWithStackTrace(const NotFoundFailure(), s);
      }
      Error.throwWithStackTrace(_failureFrom(e), s);
    } on FormatException catch (e, s) {
      log('Malformed response', name: 'characters', error: e, stackTrace: s);
      Error.throwWithStackTrace(const ServerFailure(), s);
    }
  }

  Failure _failureFrom(DioException e) => switch (e.type) {
    DioExceptionType.badResponse => ServerFailure(e.response?.statusCode),
    DioExceptionType.unknown when e.error is FormatException => const ServerFailure(),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown => const NetworkFailure(),
  };
}
