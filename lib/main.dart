import 'package:characters_data/characters_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

void main() {
  final service = CharactersService(createApiDio(logRequests: kDebugMode));
  runApp(App(charactersRepository: CharactersRepository(service)));
}
