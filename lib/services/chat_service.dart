import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // 스트림 컨트롤러들
  final StreamController<List<ChatRoom>> _chatRoomsController = 
      StreamController<List<ChatRoom>>.broadcast();
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};

  // 목업 데이터
  final Map<String, ChatRoom> _chatRooms = {};
  final Map<String, List<ChatMessage>> _messages = {};

  Stream<List<ChatRoom>> get chatRoomsStream => _chatRoomsController.stream;

  Stream<List<ChatMessage>> getMessagesStream(String roomId) {
    if (!_messageControllers.containsKey(roomId)) {
      _messageControllers[roomId] = StreamController<List<ChatMessage>>.broadcast();
    }
    return _messageControllers[roomId]!.stream;
  }

  /// 초기 목업 데이터 생성
  void initializeMockData(String currentUserId) {
    // 목업 채팅방들
    final mockRooms = [
      ChatRoom(
        id: 'room_1',
        name: '뷰티퀸과의 채팅',
        participantIds: [currentUserId, 'inf_1'],
        participantNames: {
          currentUserId: '판매사',
          'inf_1': '뷰티퀸',
        },
        participantImages: {
          currentUserId: null,
          'inf_1': 'https://picsum.photos/200/200?random=1',
        },
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        unreadCount: 2,
      ),
      ChatRoom(
        id: 'room_2',
        name: '맛집탐험가와의 채팅',
        participantIds: [currentUserId, 'inf_2'],
        participantNames: {
          currentUserId: '판매사',
          'inf_2': '맛집탐험가',
        },
        participantImages: {
          currentUserId: null,
          'inf_2': 'https://picsum.photos/200/200?random=2',
        },
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(minutes: 30)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'room_3',
        name: '패션스타일리스트와의 채팅',
        participantIds: [currentUserId, 'inf_3'],
        participantNames: {
          currentUserId: '판매사',
          'inf_3': '패션스타일리스트',
        },
        participantImages: {
          currentUserId: null,
          'inf_3': 'https://picsum.photos/200/200?random=3',
        },
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(hours: 6)),
        unreadCount: 1,
      ),
      ChatRoom(
        id: 'room_4',
        name: '게임 리뷰어와의 채팅',
        participantIds: [currentUserId, 'inf_4'],
        participantNames: {
          currentUserId: '판매사',
          'inf_4': '게임 리뷰어',
        },
        participantImages: {
          currentUserId: null,
          'inf_4': 'https://picsum.photos/200/200?random=4',
        },
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(Duration(minutes: 15)),
        unreadCount: 3,
      ),
      ChatRoom(
        id: 'room_5',
        name: '육아인플루언서와의 채팅',
        participantIds: [currentUserId, 'inf_5'],
        participantNames: {
          currentUserId: '판매사',
          'inf_5': '육아인플루언서',
        },
        participantImages: {
          currentUserId: null,
          'inf_5': 'https://picsum.photos/200/200?random=5',
        },
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(hours: 12)),
        unreadCount: 0,
      ),
    ];

    // 목업 메시지들
    final mockMessages = {
      'room_1': [
        ChatMessage(
          id: 'msg_1',
          senderId: 'inf_1',
          senderName: '뷰티퀸',
          senderProfileImage: 'https://picsum.photos/200/200?random=1',
          content: '안녕하세요! 캠페인 제안 감사합니다.',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'msg_2',
          senderId: currentUserId,
          senderName: '판매사',
          content: '네, 안녕하세요! 저희 화장품 캠페인에 관심 가져주셔서 감사합니다.',
          timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: -5)),
        ),
        ChatMessage(
          id: 'msg_3',
          senderId: 'inf_1',
          senderName: '뷰티퀸',
          senderProfileImage: 'https://picsum.photos/200/200?random=1',
          content: '제품에 대해 더 자세히 알고 싶어요. 언제 미팅이 가능하신가요?',
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'msg_4',
          senderId: 'inf_1',
          senderName: '뷰티퀸',
          senderProfileImage: 'https://picsum.photos/200/200?random=1',
          content: '포트폴리오도 함께 보내드릴게요!',
          timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          status: MessageStatus.delivered,
        ),
      ],
      'room_2': [
        ChatMessage(
          id: 'msg_5',
          senderId: 'inf_2',
          senderName: '맛집탐험가',
          senderProfileImage: 'https://picsum.photos/200/200?random=2',
          content: '음식 관련 캠페인 제안해주셔서 감사합니다!',
          timestamp: DateTime.now().subtract(Duration(hours: 5)),
        ),
        ChatMessage(
          id: 'msg_6',
          senderId: currentUserId,
          senderName: '판매사',
          content: '저희 신제품 런칭 관련해서 협업하고 싶습니다.',
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
        ),
        ChatMessage(
          id: 'msg_7',
          senderId: 'inf_2',
          senderName: '맛집탐험가',
          senderProfileImage: 'https://picsum.photos/200/200?random=2',
          content: '좋습니다! 구체적인 제품 정보와 일정을 알려주세요.',
          timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          status: MessageStatus.read,
        ),
      ],
    };

    // 데이터 저장
    for (final room in mockRooms) {
      _chatRooms[room.id] = room.copyWith(
        lastMessage: mockMessages[room.id]?.last,
      );
    }
    
    _messages.addAll(mockMessages);

    // 스트림에 전송
    _chatRoomsController.add(_chatRooms.values.toList());
  }

  /// 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    await Future.delayed(Duration(milliseconds: 500)); // 네트워크 시뮬레이션
    
    if (_chatRooms.isEmpty) {
      initializeMockData(userId);
    }

    final rooms = _chatRooms.values
        .where((room) => room.participantIds.contains(userId))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return rooms;
  }

  /// 특정 채팅방의 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(String roomId) async {
    await Future.delayed(Duration(milliseconds: 300)); // 네트워크 시뮬레이션
    
    final messages = _messages[roomId] ?? [];
    return List.from(messages);
  }

  /// 메시지 전송
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    await Future.delayed(Duration(milliseconds: 800)); // 네트워크 시뮬레이션

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: content,
      type: type,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );

    // 메시지 저장
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(message);

    // 채팅방 업데이트
    if (_chatRooms.containsKey(roomId)) {
      _chatRooms[roomId] = _chatRooms[roomId]!.copyWith(
        lastMessage: message,
        updatedAt: DateTime.now(),
      );
    }

    // 스트림 업데이트
    if (_messageControllers.containsKey(roomId)) {
      _messageControllers[roomId]!.add(_messages[roomId]!);
    }
    _chatRoomsController.add(_chatRooms.values.toList());

    return message;
  }

  /// 채팅방 생성
  Future<ChatRoom> createChatRoom({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    String? otherUserImage,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final roomId = 'room_${currentUserId}_${otherUserId}';
    
    final room = ChatRoom(
      id: roomId,
      name: '$otherUserName과의 채팅',
      participantIds: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: '나',
        otherUserId: otherUserName,
      },
      participantImages: {
        currentUserId: null,
        otherUserId: otherUserImage,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _chatRooms[roomId] = room;
    _messages[roomId] = [];

    _chatRoomsController.add(_chatRooms.values.toList());

    return room;
  }

  /// 메시지 읽음 처리
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    await Future.delayed(Duration(milliseconds: 200));

    final messages = _messages[roomId];
    if (messages != null) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].senderId != userId && 
            messages[i].status != MessageStatus.read) {
          messages[i] = messages[i].copyWith(status: MessageStatus.read);
        }
      }

      // 읽지 않은 메시지 수 업데이트
      if (_chatRooms.containsKey(roomId)) {
        _chatRooms[roomId] = _chatRooms[roomId]!.copyWith(unreadCount: 0);
      }

      // 스트림 업데이트
      if (_messageControllers.containsKey(roomId)) {
        _messageControllers[roomId]!.add(messages);
      }
      _chatRoomsController.add(_chatRooms.values.toList());
    }
  }

  /// 리소스 정리
  void dispose() {
    _chatRoomsController.close();
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
  }
}

extension on ChatRoom {
  ChatRoom copyWith({
    String? id,
    String? name,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantImages,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantImages: participantImages ?? this.participantImages,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
