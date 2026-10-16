import 'package:flutter/material.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            if (actionLabel case final label?)
              FilledButton.tonal(onPressed: onAction, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
