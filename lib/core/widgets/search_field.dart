import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    this.controller,
    this.initialValue = '',
    this.hintText,
    super.key,
  });

  final ValueChanged<String> onChanged;

  /// Owned by the caller when given; otherwise the field creates one from [initialValue].
  final TextEditingController? controller;
  final String initialValue;
  final String? hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownController;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: SearchBar(
        controller: _controller,
        hintText: widget.hintText,
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        constraints: const BoxConstraints(minHeight: 52, maxHeight: 52),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        side: WidgetStatePropertyAll(
          _focused ? BorderSide(color: colorScheme.primary, width: 2) : BorderSide.none,
        ),
        padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.only(start: 16, end: 6)),
        textStyle: WidgetStatePropertyAll(theme.textTheme.bodyLarge),
        hintStyle: WidgetStatePropertyAll(
          theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        leading: Icon(
          Icons.search,
          color: _focused ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        trailing: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) => AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: _clear,
                    ),
            ),
          ),
        ],
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
      ),
    );
  }
}
