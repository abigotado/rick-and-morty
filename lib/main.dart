import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/core/network/create_dio.dart';
import 'package:rick_and_morty/features/characters/data/characters_api.dart';
import 'package:rick_and_morty/features/characters/data/characters_repository_impl.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';

void main() {
  final repository = CharactersRepositoryImpl(CharactersApi(createDio()));
  runApp(
    RepositoryProvider<CharactersRepository>.value(
      value: repository,
      child: const App(),
    ),
  );
}
