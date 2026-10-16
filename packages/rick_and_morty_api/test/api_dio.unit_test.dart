import 'package:dio/dio.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

void main() {
  group('createApiDio', () {
    test('no arguments → public api base url', () {
      expect(createApiDio().options.baseUrl, 'https://rickandmortyapi.com/api');
    });

    test('no arguments → connect and receive timeouts set', () {
      final options = createApiDio().options;

      expect(options.connectTimeout, greaterThan(Duration.zero));
      expect(options.receiveTimeout, greaterThan(Duration.zero));
    });

    test('logRequests → adds a LogInterceptor', () {
      expect(
        createApiDio(logRequests: true).interceptors.whereType<LogInterceptor>(),
        hasLength(1),
      );
    });

    test('default → no LogInterceptor', () {
      expect(createApiDio().interceptors.whereType<LogInterceptor>(), isEmpty);
    });
  });
}
