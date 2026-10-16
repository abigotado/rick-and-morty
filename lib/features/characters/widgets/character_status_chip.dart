import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';

class CharacterStatusChip extends StatelessWidget {
  const CharacterStatusChip({required this.status, super.key});

  final CharacterStatus status;

  static const _aliveColor = Color(0xFF55B23B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      CharacterStatus.alive => ('Alive', _aliveColor),
      CharacterStatus.dead => ('Dead', theme.colorScheme.error),
      CharacterStatus.unknown => ('Unknown', theme.colorScheme.outline),
    };
    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 8),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
