import 'dart:async';

import 'package:flutter/material.dart';

class CharacterDetailsBackButton extends StatelessWidget {
  const CharacterDetailsBackButton({super.key});

  static const size = 44.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Back to characters',
      onPressed: () => unawaited(Navigator.maybePop(context)),
      icon: const Icon(Icons.chevron_left_rounded),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(size),
        minimumSize: const Size.square(size),
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.16)),
        ),
      ),
    );
  }
}
