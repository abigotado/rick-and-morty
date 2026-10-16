import 'dart:developer';

import 'package:dio/dio.dart';

Dio createApiDio({bool logRequests = false}) {
  const timeout = Duration(seconds: 10);
  return Dio(
      BaseOptions(
        baseUrl: 'https://rickandmortyapi.com/api',
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ),
    )
    ..interceptors.addAll([
      if (logRequests) LogInterceptor(logPrint: (object) => log('$object', name: 'http')),
    ]);
}
