import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/failure_message.dart';
import 'package:rick_and_morty/core/widgets/state_message.dart';
import 'package:rick_and_morty/features/characters/presentation/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/list/widgets/character_list_footer.dart';
import 'package:rick_and_morty/features/characters/presentation/list/widgets/character_sliver_items.dart';

class CharacterListContent extends StatelessWidget {
  const CharacterListContent({required this.state, super.key});

  final CharactersState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CharactersState(status: CharactersStatus.initial || CharactersStatus.loading) =>
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator(semanticsLabel: 'Loading')),
        ),
      CharactersState(status: CharactersStatus.failure, :final failure) => SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessage(
          icon: Icons.cloud_off_outlined,
          title: failure?.message ?? 'Something went wrong.',
          actionLabel: 'Retry',
          onAction: () => context.read<CharactersBloc>().add(const CharactersRetried()),
        ),
      ),
      CharactersState(characters: []) => const SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessage(icon: Icons.search_off, title: 'No characters found'),
      ),
      CharactersState(:final characters, :final hasMore, :final nextPageStatus) => SliverSafeArea(
        top: false,
        sliver: SliverMainAxisGroup(
          slivers: [
            CharacterSliverItems(characters: characters),
            if (hasMore) SliverToBoxAdapter(child: CharacterListFooter(status: nextPageStatus)),
          ],
        ),
      ),
    };
  }
}
