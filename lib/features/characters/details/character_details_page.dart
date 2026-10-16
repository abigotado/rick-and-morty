import 'dart:async';

import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/details/character_details_view.dart';
import 'package:rick_and_morty/features/characters/details/cubit/character_details_cubit.dart';

class CharacterDetailsPage extends StatelessWidget {
  const CharacterDetailsPage({required this.characterId, this.character, super.key});

  final int characterId;
  final CharacterEntity? character;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CharacterDetailsCubit(
          charactersRepository: context.read<ICharactersRepository>(),
          characterId: characterId,
          initialCharacter: character,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const CharacterDetailsView(),
    );
  }
}
