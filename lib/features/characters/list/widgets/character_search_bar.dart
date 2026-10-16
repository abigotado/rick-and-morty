import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/widgets/search_field.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';

class CharacterSearchBar extends StatelessWidget {
  const CharacterSearchBar({required this.controller, super.key});

  final TextEditingController controller;

  static const double height = 76;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SearchField(
            controller: controller,
            hintText: 'Search by name',
            onChanged: (query) => context.read<CharactersBloc>().add(CharactersQueryChanged(query)),
          ),
        ),
      ),
    );
  }
}
