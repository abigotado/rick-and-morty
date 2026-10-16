import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/highlighted_text.dart';
import 'package:rick_and_morty/core/widgets/pressable_surface.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';
import 'package:rick_and_morty/features/characters/widgets/character_status_line.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({required this.character, this.query = '', super.key});

  final CharacterEntity character;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableSurface(
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: CharacterImage(url: character.imageUrl)),
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
