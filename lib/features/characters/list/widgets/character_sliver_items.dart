import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_tile.dart';

class CharacterSliverItems extends StatelessWidget {
  const CharacterSliverItems({
    required this.characters,
    required this.entrance,
    this.query = '',
    super.key,
  });

  final List<CharacterEntity> characters;
  final Animation<double> entrance;
  final String query;

  static const gridBreakpoint = 600.0;
  static const listPadding = EdgeInsets.fromLTRB(16, 4, 16, 8);
  static const gridPadding = EdgeInsets.fromLTRB(16, 8, 16, 16);
  static const itemSpacing = 10.0;
  static const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.74,
  );

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= gridBreakpoint) {
      return SliverPadding(
        padding: gridPadding,
        sliver: SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return StaggeredEntrance(
              key: ValueKey(character.id),
              animation: entrance,
              index: index,
              child: CharacterCard(character: character, query: query),
            );
          },
        ),
      );
    }
    return SliverPadding(
      padding: listPadding,
      sliver: SliverList.separated(
        itemCount: characters.length,
        separatorBuilder: (context, index) => const SizedBox(height: itemSpacing),
        itemBuilder: (context, index) {
          final character = characters[index];
          return StaggeredEntrance(
            key: ValueKey(character.id),
            animation: entrance,
            index: index,
            child: CharacterTile(character: character, query: query),
          );
        },
      ),
    );
  }
}
