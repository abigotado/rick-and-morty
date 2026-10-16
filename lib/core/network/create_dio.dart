import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _baseUrl = 'https://rickandmortyapi.com/api';
const _timeout = Duration(seconds: 10);

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(logPrint: (object) => log('$object', name: 'http')));
  }
  return dio;
}
