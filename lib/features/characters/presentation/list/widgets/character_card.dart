import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_image.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_status_chip.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: CharacterImage(character: character)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  character.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                CharacterStatusChip(status: character.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
