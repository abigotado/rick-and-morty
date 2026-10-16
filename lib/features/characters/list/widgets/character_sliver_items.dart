import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_tile.dart';

class CharacterSliverItems extends StatelessWidget {
  const CharacterSliverItems({required this.characters, super.key});

  final List<CharacterEntity> characters;

  static const _gridBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= _gridBreakpoint) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return CharacterCard(key: ValueKey(character.id), character: character);
          },
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList.separated(
        itemCount: characters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final character = characters[index];
          return CharacterTile(key: ValueKey(character.id), character: character);
        },
      ),
    );
  }
}
