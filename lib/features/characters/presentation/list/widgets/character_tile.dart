import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_image.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_status_chip.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 16,
          children: [
            SizedBox.square(
              dimension: 72,
              child: CharacterImage(
                character: character,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                  CharacterStatusChip(status: character.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
