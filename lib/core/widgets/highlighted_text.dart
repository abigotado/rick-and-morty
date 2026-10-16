import 'package:flutter/material.dart';

/// Shows [text] with the first case-insensitive occurrence of [highlight] in [highlightColor].
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    required this.highlight,
    required this.highlightColor,
    this.style,
    super.key,
  });

  final String text;
  final String highlight;
  final Color highlightColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final match = highlight.isEmpty
        ? null
        : RegExp(RegExp.escape(highlight), caseSensitive: false).firstMatch(text);
    if (match == null) {
      return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final Match(:start, :end) = match;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(color: highlightColor),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
