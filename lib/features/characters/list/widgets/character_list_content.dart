import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/widgets/portal_illustration.dart';
import 'package:rick_and_morty/core/widgets/state_message.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_list_footer.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_list_skeleton.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_sliver_items.dart';

class CharacterListContent extends StatelessWidget {
  const CharacterListContent({
    required this.state,
    required this.entrance,
    required this.onClearSearch,
    required this.onCharacterTap,
    super.key,
  });

  final CharactersState state;
  final Animation<double> entrance;
  final VoidCallback onClearSearch;
  final ValueChanged<CharacterEntity> onCharacterTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (state) {
      CharactersState(status: CharactersStatus.initial || CharactersStatus.loading) =>
        const CharacterListSkeleton(),
      CharactersState(status: CharactersStatus.failure, :final failure) => SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessage(
          illustration: PortalIllustration(
            icon: Icons.priority_high_rounded,
            color: colorScheme.error,
            broken: true,
          ),
          title: failure?.title ?? 'Something went wrong',
          message: failure?.message,
          action: FilledButton.icon(
            onPressed: () => context.read<CharactersBloc>().add(const CharactersRetried()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ),
      ),
      CharactersState(characters: [], query: '') => SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessage(
          illustration: PortalIllustration(
            icon: Icons.search_off_rounded,
            color: colorScheme.primary,
          ),
          title: 'No characters found',
        ),
      ),
      CharactersState(characters: [], :final query) => SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessage(
          illustration: PortalIllustration(icon: Icons.close_rounded, color: colorScheme.primary),
          title: 'No one by that name',
          message:
              'Nothing matches “$query” in this dimension. '
              'Check the spelling or try another name.',
          action: OutlinedButton(onPressed: onClearSearch, child: const Text('Clear search')),
        ),
      ),
      CharactersState(:final characters, :final query, :final hasMore, :final nextPageStatus) =>
        SliverSafeArea(
          top: false,
          sliver: SliverMainAxisGroup(
            slivers: [
              CharacterSliverItems(
                characters: characters,
                query: query,
                entrance: entrance,
                onCharacterTap: onCharacterTap,
              ),
              if (hasMore) SliverToBoxAdapter(child: CharacterListFooter(status: nextPageStatus)),
            ],
          ),
        ),
    };
  }
}
