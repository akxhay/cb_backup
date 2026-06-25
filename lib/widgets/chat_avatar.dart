import 'package:flutter/material.dart';

import '../theme/chat_theme.dart';

class ChatAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool isGroup;

  const ChatAvatar({
    super.key,
    required this.name,
    this.radius = 26,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ChatTheme.avatarColor(name);
    final label = isGroup ? name.substring(0, 1).toUpperCase() : ChatTheme.initials(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: isGroup
          ? Icon(Icons.group, color: Colors.white, size: radius * 0.9)
          : Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.72,
              ),
            ),
    );
  }
}