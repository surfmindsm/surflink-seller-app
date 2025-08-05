enum MessageType { text, image, file }

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileSize,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderProfileImage: json['sender_profile_image'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_profile_image': senderProfileImage,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}

class ChatRoom {
  final String id;
  final String name;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantImages;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      participantNames: Map<String, String>.from(json['participant_names'] ?? {}),
      participantImages: Map<String, String?>.from(json['participant_images'] ?? {}),
      lastMessage: json['last_message'] != null 
        ? ChatMessage.fromJson(json['last_message']) 
        : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'participant_images': participantImages,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getOtherParticipantName(String currentUserId) {
    final otherParticipant = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherParticipant] ?? 'Unknown';
  }

  String? getOtherParticipantImage(String currentUserId) {
    final otherParticipant = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantImages[otherParticipant];
  }
}
