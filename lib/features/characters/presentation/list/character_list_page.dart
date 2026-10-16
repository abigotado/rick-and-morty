import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/list/character_list_view.dart';

class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CharactersBloc(context.read<CharactersRepository>())..add(const CharactersStarted()),
      child: const CharacterListView(),
    );
  }
}
