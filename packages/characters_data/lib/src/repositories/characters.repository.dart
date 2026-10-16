import 'dart:developer';

import 'package:characters_data/src/mappers/character.mapper.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

class CharactersRepository implements ICharactersRepository {
  const CharactersRepository(this._service);

  final ICharactersService _service;

  @override
  Future<CharactersPageEntity> getCharacters({int page = 1, String name = ''}) => _guard(
    () async => CharacterMapper.toPageEntity(
      await _service.getCharacters(page: page, name: name),
    ),
    onNotFound: () => const CharactersPageEntity.empty(),
  );

  @override
  Future<CharacterEntity> getCharacter(int id) =>
      _guard(() async => CharacterMapper.toEntity(await _service.getCharacter(id)));

  Future<T> _guard<T>(Future<T> Function() request, {T Function()? onNotFound}) async {
    try {
      return await request();
    } on ApiException catch (e, s) {
      if (e case ApiResponseException(statusCode: 404)) {
        if (onNotFound != null) return onNotFound();
        Error.throwWithStackTrace(const NotFoundFailure(), s);
      }
      Error.throwWithStackTrace(_toFailure(e, s), s);
    } on FormatException catch (e, s) {
      Error.throwWithStackTrace(_malformed(e, s), s);
    }
  }

  Failure _toFailure(ApiException e, StackTrace s) => switch (e) {
    ApiConnectionException() => const NetworkFailure(),
    ApiResponseException(:final statusCode) => ServerFailure(statusCode),
    ApiFormatException(:final cause) => _malformed(cause, s),
  };

  Failure _malformed(Object cause, StackTrace s) {
    log('Malformed response', name: 'characters', error: cause, stackTrace: s);
    return const ServerFailure();
  }
}
