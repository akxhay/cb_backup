import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;
  final bool autofocus;

  const ChatSearchBar({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.showClear = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          style: const TextStyle(fontSize: 15),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
            prefixIcon: Icon(Icons.search_rounded, size: 22, color: cs.onSurfaceVariant),
            suffixIcon: showClear
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: onClear,
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.65),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}