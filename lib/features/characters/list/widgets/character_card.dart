import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/highlighted_text.dart';
import 'package:rick_and_morty/core/widgets/pressable_surface.dart';
import 'package:rick_and_morty/features/characters/widgets/character_hero.dart';
import 'package:rick_and_morty/features/characters/widgets/character_status_line.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({required this.character, this.query = '', this.onTap, super.key});

  final CharacterEntity character;
  final String query;
  final VoidCallback? onTap;

  static const _radius = Radius.circular(22);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableSurface(
      onTap: onTap,
      borderRadius: const BorderRadius.all(_radius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CharacterHero(
              characterId: character.id,
              url: character.imageUrl,
              borderRadius: const BorderRadius.vertical(top: _radius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                HighlightedText(
                  character.name,
                  highlight: query,
                  highlightColor: theme.colorScheme.primary,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                CharacterStatusLine(character: character),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
