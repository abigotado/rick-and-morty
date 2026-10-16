import 'dart:async';

import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/portal_illustration.dart';
import 'package:rick_and_morty/core/widgets/state_message.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';

class CharacterDetailsFailure extends StatelessWidget {
  const CharacterDetailsFailure({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Center(
                child: StateMessage(
                  illustration: PortalIllustration(
                    icon: Icons.priority_high_rounded,
                    color: Theme.of(context).colorScheme.error,
                    broken: true,
                  ),
                  title: failure.title,
                  message: failure.message,
                  action: switch (failure) {
                    NotFoundFailure() => OutlinedButton(
                      onPressed: () => unawaited(Navigator.maybePop(context)),
                      child: const Text('Back to characters'),
                    ),
                    NetworkFailure() || ServerFailure() => FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
