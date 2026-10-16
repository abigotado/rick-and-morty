import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    required this.illustration,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final Widget illustration;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FadeIn(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                illustration,
                Column(
                  spacing: 8,
                  children: [
                    Text(title, textAlign: TextAlign.center, style: textTheme.headlineSmall),
                    if (message case final message?)
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                ?action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
