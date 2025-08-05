import 'package:flutter/material.dart';
import '../../models/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderProfileImage != null
                  ? NetworkImage(message.senderProfileImage!)
                  : null,
              child: message.senderProfileImage == null
                  ? Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0]
                          : '?',
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 메시지 버블
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMyMessage
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isMyMessage
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                  ),
                  child: _buildMessageContent(context),
                ),
                
                const SizedBox(height: 4),
                
                // 시간과 상태
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isMyMessage) ...[
                      const SizedBox(width: 4),
                      _buildMessageStatus(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            // 내 프로필 이미지는 표시하지 않음 (간단하게)
            const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isMyMessage ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.fileUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.fileUrl!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: isMyMessage ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: isMyMessage ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? '파일',
                    style: TextStyle(
                      color: isMyMessage ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null)
                    Text(
                      _formatFileSize(message.fileSize!),
                      style: TextStyle(
                        color: isMyMessage
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final ampm = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$ampm ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}
