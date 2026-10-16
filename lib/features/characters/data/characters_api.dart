import 'package:dio/dio.dart';

class CharactersApi {
  const CharactersApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchCharacters({required int page, String name = ''}) {
    return _get(
      '/character/',
      queryParameters: {'page': page, if (name.isNotEmpty) 'name': name},
    );
  }

  Future<Map<String, dynamic>> fetchCharacter(int id) => _get('/character/$id');

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, Object>? queryParameters,
  }) async {
    final response = await _dio.get<Object?>(path, queryParameters: queryParameters);
    return switch (response.data) {
      final Map<String, dynamic> data => data,
      final other => throw FormatException('Expected a JSON object, got ${other.runtimeType}'),
    };
  }
}
