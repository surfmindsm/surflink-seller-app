import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../models/chat_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      if (authProvider.user?.id != null) {
        chatProvider.loadChatRooms(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: '채팅방 목록을 불러오는 중...'),
            );
          }

          if (chatProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '채팅방을 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chatProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      chatProvider.clearError();
                      if (authProvider.user?.id != null) {
                        chatProvider.loadChatRooms(authProvider.user!.id);
                      }
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final chatRooms = chatProvider.chatRooms;

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 대화가 없습니다',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '캠페인에서 인플루언서와\n대화를 시작해보세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (authProvider.user?.id != null) {
                await chatProvider.loadChatRooms(authProvider.user!.id);
              }
            },
            child: ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return ChatRoomTile(
                  chatRoom: chatRoom,
                  currentUserId: authProvider.user?.id ?? '',
                  onTap: () {
                    context.push('/chat/${chatRoom.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatRoomTile({
    Key? key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUserName = chatRoom.getOtherParticipantName(currentUserId);
    final otherUserImage = chatRoom.getOtherParticipantImage(currentUserId);
    final hasUnread = chatRoom.unreadCount > 0;

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: otherUserImage != null
            ? NetworkImage(otherUserImage)
            : null,
        child: otherUserImage == null
            ? Text(
                otherUserName.isNotEmpty ? otherUserName[0] : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUserName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (chatRoom.lastMessage != null)
            Text(
              _formatTime(chatRoom.lastMessage!.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chatRoom.lastMessage?.content ?? '대화를 시작해보세요',
              style: TextStyle(
                color: hasUnread ? Colors.black87 : Colors.grey[600],
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chatRoom.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '어제';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else {
        return '${timestamp.month}/${timestamp.day}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금';
    }
  }
}
