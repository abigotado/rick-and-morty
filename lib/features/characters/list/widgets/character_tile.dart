import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/highlighted_text.dart';
import 'package:rick_and_morty/core/widgets/pressable_surface.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';
import 'package:rick_and_morty/features/characters/widgets/character_status_line.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({required this.character, this.query = '', super.key});

  final CharacterEntity character;
  final String query;

  static const imageSize = 68.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableSurface(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 14,
          children: [
            SizedBox.square(
              dimension: imageSize,
              child: CharacterImage(
                url: character.imageUrl,
                decodeExtent: imageSize,
                borderRadius: const BorderRadius.all(Radius.circular(14)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  HighlightedText(
                    character.name,
                    highlight: query,
                    highlightColor: theme.colorScheme.primary,
                    style: theme.textTheme.titleMedium,
                  ),
                  CharacterStatusLine(character: character),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
