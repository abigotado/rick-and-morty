import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/widgets/collapsing_header.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_search_bar.dart';

class CharacterListHeader extends StatelessWidget {
  const CharacterListHeader({required this.searchController, super.key});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return CollapsingHeader(
      title: 'Characters',
      subtitle: const _CountCaption(),
      bottomHeight: CharacterSearchBar.height,
      bottom: CharacterSearchBar(controller: searchController),
    );
  }
}

class _CountCaption extends StatelessWidget {
  const _CountCaption();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CharactersBloc, CharactersState, String>(
      selector: (state) => switch (state) {
        CharactersState(status: CharactersStatus.initial || CharactersStatus.loading) =>
          'Opening a portal…',
        CharactersState(status: CharactersStatus.success, query: '', :final totalCount) =>
          '$totalCount across the multiverse',
        CharactersState(status: CharactersStatus.success, totalCount: 0) => 'No matches',
        CharactersState(status: CharactersStatus.success, totalCount: 1) => '1 match',
        CharactersState(status: CharactersStatus.success, :final totalCount) =>
          '$totalCount matches',
        CharactersState(status: CharactersStatus.failure) => '',
      },
      builder: (context, caption) => Semantics(
        liveRegion: true,
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [...previousChildren, ?currentChild],
          ),
          child: Text(caption, key: ValueKey(caption)),
        ),
      ),
    );
  }
}
