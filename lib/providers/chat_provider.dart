import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  // 상태 관리
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;
  
  List<ChatRoom> _chatRooms = [];
  Map<String, List<ChatMessage>> _messagesCache = {};
  
  // 스트림 구독
  StreamSubscription<List<ChatRoom>>? _chatRoomsSubscription;
  Map<String, StreamSubscription<List<ChatMessage>>> _messageSubscriptions = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;
  List<ChatRoom> get chatRooms => _chatRooms;
  
  List<ChatMessage> getMessages(String roomId) {
    return _messagesCache[roomId] ?? [];
  }

  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }

  /// 채팅방 목록 로드
  Future<void> loadChatRooms(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      // 스트림 구독 시작
      _chatRoomsSubscription?.cancel();
      _chatRoomsSubscription = _chatService.chatRoomsStream.listen(
        (rooms) {
          _chatRooms = rooms;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          notifyListeners();
        },
      );

      // 초기 데이터 로드
      final rooms = await _chatService.getChatRooms(userId);
      _chatRooms = rooms;
      
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Chat rooms load error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 채팅방의 메시지들 로드
  Future<void> loadMessages(String roomId) async {
    _setLoadingMessages(true);

    try {
      // 스트림 구독 시작
      if (!_messageSubscriptions.containsKey(roomId)) {
        _messageSubscriptions[roomId] = _chatService.getMessagesStream(roomId).listen(
          (messages) {
            _messagesCache[roomId] = messages;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
      }

      // 초기 메시지 로드
      final messages = await _chatService.getMessages(roomId);
      _messagesCache[roomId] = messages;
      
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Messages load error: $e');
      }
    } finally {
      _setLoadingMessages(false);
    }
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderProfileImage,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    if (content.trim().isEmpty) return;

    _setSending(true);
    _error = null;

    try {
      // 임시 메시지 추가 (즉시 UI 업데이트)
      final tempMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        content: content.trim(),
        type: type,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
      );

      // 캐시에 임시 메시지 추가
      if (!_messagesCache.containsKey(roomId)) {
        _messagesCache[roomId] = [];
      }
      _messagesCache[roomId]!.add(tempMessage);
      notifyListeners();

      // 실제 메시지 전송
      final sentMessage = await _chatService.sendMessage(
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        content: content.trim(),
        type: type,
      );

      // 임시 메시지를 실제 메시지로 교체
      final messages = _messagesCache[roomId]!;
      final tempIndex = messages.indexWhere((m) => m.id == tempMessage.id);
      if (tempIndex != -1) {
        messages[tempIndex] = sentMessage;
        notifyListeners();
      }

    } catch (e) {
      _error = '메시지 전송에 실패했습니다: $e';
      
      // 임시 메시지를 실패 상태로 변경
      final messages = _messagesCache[roomId];
      if (messages != null) {
        final tempIndex = messages.indexWhere((m) => m.id.startsWith('temp_'));
        if (tempIndex != -1) {
          messages[tempIndex] = messages[tempIndex].copyWith(
            status: MessageStatus.failed,
          );
          notifyListeners();
        }
      }
      
      if (kDebugMode) {
        print('Send message error: $e');
      }
    } finally {
      _setSending(false);
    }
  }

  /// 새 채팅방 생성
  Future<ChatRoom?> createChatRoom({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    String? otherUserImage,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // 이미 존재하는 채팅방 확인
      final existingRoom = _chatRooms.firstWhere(
        (room) => room.participantIds.contains(currentUserId) &&
                 room.participantIds.contains(otherUserId),
        orElse: () => ChatRoom(
          id: '',
          name: '',
          participantIds: [],
          participantNames: {},
          participantImages: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (existingRoom.id.isNotEmpty) {
        return existingRoom; // 이미 존재하는 채팅방 반환
      }

      // 새 채팅방 생성
      final newRoom = await _chatService.createChatRoom(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserImage: otherUserImage,
      );

      return newRoom;

    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Create chat room error: $e');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 메시지 읽음 처리
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(roomId, userId);
    } catch (e) {
      if (kDebugMode) {
        print('Mark as read error: $e');
      }
    }
  }

  /// 특정 채팅방 조회
  ChatRoom? getChatRoom(String roomId) {
    try {
      return _chatRooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  /// 상태 설정 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMessages(bool loading) {
    _isLoadingMessages = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 리소스 정리
  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    _chatService.dispose();
    super.dispose();
  }
}
