import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../models/chat.dart';
import '../services/chat_parser.dart';
import '../theme/chat_theme.dart';
import 'full_screen_image_viewer.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSelf;
  final String? mediaFullPath;
  final bool showSenderName;
  final bool groupedAbove;
  final bool groupedBelow;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSelf,
    this.mediaFullPath,
    this.showSenderName = false,
    this.groupedAbove = false,
    this.groupedBelow = false,
  });

  Future<void> _openMedia(BuildContext context) async {
    if (mediaFullPath == null) return;

    if (message.type == MessageType.image) {
      await FullScreenImageViewer.show(
        context,
        imagePath: mediaFullPath!,
        caption: message.text.isNotEmpty ? message.text : null,
      );
      return;
    }

    final result = await OpenFilex.open(mediaFullPath!);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  IconData _getMediaIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
        return Icons.image_outlined;
      case MessageType.video:
        return Icons.play_circle_fill_rounded;
      case MessageType.audio:
        return Icons.mic_rounded;
      case MessageType.document:
        return Icons.description_outlined;
      default:
        return Icons.attach_file_rounded;
    }
  }

  Color _mediaAccent(MessageType type) {
    switch (type) {
      case MessageType.video:
        return const Color(0xFFE542A3);
      case MessageType.audio:
        return const Color(0xFF53BDEB);
      case MessageType.document:
        return const Color(0xFF7F66FF);
      default:
        return const Color(0xFF8696A0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _buildSystemMessage(context);
    }

    final isStickerMsg =
        message.type == MessageType.image && isSticker(message);

    if (isStickerMsg && mediaFullPath != null) {
      return _buildSticker(context);
    }

    final bubbleColor = isSelf
        ? ChatTheme.sentBubbleColor(context)
        : ChatTheme.receivedBubbleColor(context);
    final textColor = isSelf
        ? ChatTheme.sentTextColor(context)
        : ChatTheme.receivedTextColor(context);
    final timeColor =
        ChatTheme.timestampColor(context, isSelf: isSelf);
    final align = isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final hasMedia = message.mediaPath != null && mediaFullPath != null;

    Widget content;
    if (hasMedia) {
      content = _buildMediaContent(context, textColor, align);
    } else {
      content = Text(
        message.text,
        style: TextStyle(color: textColor, height: 1.38, fontSize: 15.5),
      );
    }

    final showName = !isSelf && showSenderName && !groupedAbove;
    final radius = ChatTheme.bubbleBorderRadius(
      isSelf: isSelf,
      groupedAbove: groupedAbove,
      groupedBelow: groupedBelow,
    );

    final bubbleContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: _TimestampRow(
            time: message.formattedTime,
            isEdited: message.isEdited,
            color: timeColor,
          ),
        ),
      ],
    );

    final isMediaOnly = hasMedia &&
        message.type == MessageType.image &&
        message.text.isEmpty;

    return Container(
      margin: ChatTheme.bubbleMargin(
        isSelf: isSelf,
        groupedAbove: groupedAbove,
        groupedBelow: groupedBelow,
        showSenderName: showName,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                message.sender,
                style: TextStyle(
                  color: ChatTheme.senderNameColor(message.sender),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: isMediaOnly ? Colors.transparent : bubbleColor,
              borderRadius: radius,
              boxShadow: isMediaOnly
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMediaOnly ? 0 : 10,
                vertical: isMediaOnly ? 0 : 7,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ChatTheme.bubbleMaxWidth(context),
                ),
                child: bubbleContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ChatTheme.systemPillColor(context),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: ChatTheme.datePillTextColor(context),
            fontSize: 12.5,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSticker(BuildContext context) {
    return Container(
      margin: ChatTheme.bubbleMargin(
        isSelf: isSelf,
        groupedAbove: groupedAbove,
        groupedBelow: groupedBelow,
        showSenderName: false,
      ),
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _openMedia(context),
        child: Image.file(
          File(mediaFullPath!),
          width: 140,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  Widget _buildMediaContent(
    BuildContext context,
    Color textColor,
    CrossAxisAlignment align,
  ) {
    if (message.type == MessageType.image) {
      return _buildImageContent(context, textColor, align);
    }
    if (message.type == MessageType.video) {
      return _buildVideoContent(context, textColor);
    }
    return _buildFileContent(context, textColor);
  }

  Widget _buildImageContent(
    BuildContext context,
    Color textColor,
    CrossAxisAlignment align,
  ) {
    final maxW = ChatTheme.bubbleMaxWidth(context) - 4;
    return GestureDetector(
      onTap: () => _openMedia(context),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(mediaFullPath!),
              width: maxW,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: maxW,
                height: 160,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 40),
              ),
            ),
          ),
          if (message.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context, Color textColor) {
    final filename = message.mediaPath!.split(RegExp(r'[/\\]')).last;
    return GestureDetector(
      onTap: () => _openMedia(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ChatTheme.bubbleMaxWidth(context) - 20,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.videocam_rounded,
                  size: 48,
                  color: textColor.withValues(alpha: 0.35),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
              ),
            ],
          ),
          if (message.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              filename,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileContent(BuildContext context, Color textColor) {
    final filename = message.mediaPath!.split(RegExp(r'[/\\]')).last;
    final accent = _mediaAccent(message.type);

    return GestureDetector(
      onTap: () => _openMedia(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getMediaIcon(message.type), color: accent, size: 26),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (message.text.isNotEmpty) const SizedBox(height: 2),
                Text(
                  filename,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 12.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.type == MessageType.audio) ...[
                  const SizedBox(height: 6),
                  _VoiceWaveform(color: accent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimestampRow extends StatelessWidget {
  final String time;
  final bool isEdited;
  final Color color;

  const _TimestampRow({
    required this.time,
    required this.isEdited,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w400),
        ),
        if (isEdited)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'edited',
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class _VoiceWaveform extends StatelessWidget {
  final Color color;

  const _VoiceWaveform({required this.color});

  @override
  Widget build(BuildContext context) {
    const heights = [6.0, 12.0, 8.0, 16.0, 10.0, 14.0, 7.0, 18.0, 9.0, 13.0, 6.0, 11.0];
    return Row(
      children: [
        for (final h in heights)
          Container(
            width: 3,
            height: h,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}