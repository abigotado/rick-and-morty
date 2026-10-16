import 'dart:math' as math;

import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/widgets/character_status_chip.dart';

class CharacterStatusLine extends StatelessWidget {
  const CharacterStatusLine({required this.character, super.key});

  final CharacterEntity character;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        spacing: spacing,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: math.max(0, constraints.maxWidth - spacing)),
            child: CharacterStatusChip(status: character.status),
          ),
          Flexible(
            child: Text(
              character.species,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
