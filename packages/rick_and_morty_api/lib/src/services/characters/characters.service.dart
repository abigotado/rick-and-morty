import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/src/dto/dto.dart';
import 'package:rick_and_morty_api/src/exceptions/api_exception.dart';
import 'package:rick_and_morty_api/src/services/characters/characters.api.dart';
import 'package:rick_and_morty_api/src/services/characters/characters.service.interface.dart';

class CharactersService implements ICharactersService {
  CharactersService(Dio dio) : _api = CharactersApi(dio);

  final CharactersApi _api;

  @override
  Future<CharactersPageDTO> getCharacters({required int page, String name = ''}) =>
      _guard(() => _api.getCharacters(page, name: name.isEmpty ? null : name));

  @override
  Future<CharacterDTO> getCharacter(int id) => _guard(() => _api.getCharacter(id));

  Future<T> _guard<T extends Object>(Future<T?> Function() request) async {
    try {
      return await request() ?? (throw const ApiFormatException(FormatException('Empty body')));
    } on DioException catch (e, s) {
      Error.throwWithStackTrace(_fromDio(e), s);
    } on CheckedFromJsonException catch (e, s) {
      Error.throwWithStackTrace(ApiFormatException(e), s);
    }
  }

  ApiException _fromDio(DioException e) => switch (e.type) {
    DioExceptionType.badResponse => ApiResponseException(e.response?.statusCode),
    DioExceptionType.unknown when e.error is FormatException || e.error is TypeError =>
      ApiFormatException(e.error!),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown => const ApiConnectionException(),
  };
}
