import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isSending;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    this.isSending = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 첨부 버튼
            IconButton(
              onPressed: isSending ? null : () {
                _showAttachmentOptions(context);
              },
              icon: Icon(
                Icons.add,
                color: isSending ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
            
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  enabled: !isSending,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: isSending ? null : (text) {
                    if (text.trim().isNotEmpty) {
                      onSendMessage(text.trim());
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 전송 버튼
            Container(
              decoration: BoxDecoration(
                color: isSending 
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isSending ? null : () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    onSendMessage(text);
                  }
                },
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
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
            
            Text(
              '첨부파일',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachmentOption(
                  icon: Icons.photo_camera,
                  label: '카메라',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('카메라 기능은 곧 구현됩니다')),
                    );
                  },
                ),
                _AttachmentOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('갤러리 기능은 곧 구현됩니다')),
                    );
                  },
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: '파일',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('파일 첨부 기능은 곧 구현됩니다')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
