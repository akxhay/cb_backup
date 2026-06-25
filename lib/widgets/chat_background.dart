import 'package:flutter/material.dart';

import '../theme/chat_theme.dart';

/// Subtle wallpaper pattern similar to WhatsApp chat backgrounds.
class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ChatTheme.chatBackground(context),
      child: CustomPaint(
        painter: _ChatPatternPainter(
          isDark: ChatTheme.isDark(context),
        ),
        child: child,
      ),
    );
  }
}

class _ChatPatternPainter extends CustomPainter {
  final bool isDark;

  _ChatPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final dotColor = isDark
        ? const Color(0xFF1A2530).withValues(alpha: 0.6)
        : const Color(0xFFCBD5CE).withValues(alpha: 0.45);

    final paint = Paint()..color = dotColor;
    const spacing = 28.0;
    const dotRadius = 1.2;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final offsetX = (y / spacing).floor().isEven ? 0.0 : spacing / 2;
        canvas.drawCircle(Offset(x + offsetX, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChatPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}