import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 메시지 로드
      chatProvider.loadMessages(widget.roomId);
      
      // 읽음 처리
      if (authProvider.user?.id != null) {
        chatProvider.markMessagesAsRead(widget.roomId, authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final chatRoom = chatProvider.getChatRoom(widget.roomId);
            if (chatRoom == null) {
              return const Text('채팅');
            }

            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final otherUserName = chatRoom.getOtherParticipantName(
              authProvider.user?.id ?? '',
            );
            final otherUserImage = chatRoom.getOtherParticipantImage(
              authProvider.user?.id ?? '',
            );

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: otherUserImage != null
                      ? NetworkImage(otherUserImage)
                      : null,
                  child: otherUserImage == null
                      ? Text(
                          otherUserName.isNotEmpty ? otherUserName[0] : '?',
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    otherUserName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProvider, authProvider, child) {
                final messages = chatProvider.getMessages(widget.roomId);
                final currentUserId = authProvider.user?.id ?? '';

                if (chatProvider.isLoadingMessages && messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (messages.isEmpty) {
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
                          '대화를 시작해보세요',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 메시지가 업데이트될 때마다 자동 스크롤
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = message.senderId == currentUserId;
                    
                    // 날짜 구분선 표시
                    bool showDateSeparator = false;
                    if (index == 0) {
                      showDateSeparator = true;
                    } else {
                      final prevMessage = messages[index - 1];
                      final currentDate = DateTime(
                        message.timestamp.year,
                        message.timestamp.month,
                        message.timestamp.day,
                      );
                      final prevDate = DateTime(
                        prevMessage.timestamp.year,
                        prevMessage.timestamp.month,
                        prevMessage.timestamp.day,
                      );
                      showDateSeparator = !currentDate.isAtSameMomentAs(prevDate);
                    }

                    return Column(
                      children: [
                        if (showDateSeparator)
                          _buildDateSeparator(message.timestamp),
                        
                        MessageBubble(
                          message: message,
                          isMyMessage: isMyMessage,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 메시지 입력
          Consumer2<ChatProvider, AuthProvider>(
            builder: (context, chatProvider, authProvider, child) {
              return MessageInput(
                controller: _messageController,
                onSendMessage: (content) async {
                  if (content.trim().isEmpty) return;

                  final user = authProvider.user;
                  if (user == null) return;

                  await chatProvider.sendMessage(
                    roomId: widget.roomId,
                    senderId: user.id,
                    senderName: user.name,
                    senderProfileImage: user.profileImage,
                    content: content,
                  );

                  _messageController.clear();
                  
                  // 메시지 전송 후 스크롤
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                },
                isSending: chatProvider.isSending,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = '오늘';
    } else if (messageDate.isAtSameMomentAs(today.subtract(Duration(days: 1)))) {
      dateText = '어제';
    } else {
      dateText = '${date.month}월 ${date.day}일';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('알림 끄기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 기능은 곧 구현됩니다')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('차단하기'),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmDialog(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고 기능은 곧 구현됩니다')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('이 사용자를 차단하시겠습니까?\n차단된 사용자는 메시지를 보낼 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('차단 기능은 곧 구현됩니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }
}
