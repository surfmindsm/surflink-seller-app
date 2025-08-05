import 'dart:async';
import 'dart:math';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Random _random = Random();

  // 실시간 알림을 위한 스트림
  final StreamController<List<AppNotification>> _notificationsController = StreamController.broadcast();
  final StreamController<int> _unreadCountController = StreamController.broadcast();
  
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // 모든 알림 가져오기
  Future<List<AppNotification>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    NotificationType? type,
    NotificationStatus? status,
    NotificationPriority? priority,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // API 호출 시뮬레이션

    // 목업 데이터 생성
    final notifications = _generateMockNotifications(userId, limit ?? 20);
    
    // 필터링
    var filteredNotifications = notifications.where((notification) {
      if (type != null && notification.type != type) return false;
      if (status != null && notification.status != status) return false;
      if (priority != null && notification.priority != priority) return false;
      return true;
    }).toList();

    // 최신순 정렬
    filteredNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 오프셋과 제한 적용
    if (offset != null) {
      filteredNotifications = filteredNotifications.skip(offset).toList();
    }
    if (limit != null) {
      filteredNotifications = filteredNotifications.take(limit).toList();
    }

    return filteredNotifications;
  }

  // 읽지 않은 알림 수 가져오기
  Future<int> getUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _random.nextInt(5) + 1; // 1-5개 사이의 랜덤 숫자
  }

  // 알림 읽음 처리
  Future<bool> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // 성공 시뮬레이션
  }

  // 여러 알림 읽음 처리
  Future<bool> markMultipleAsRead(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  // 모든 알림 읽음 처리
  Future<bool> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  // 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // 여러 알림 삭제
  Future<bool> deleteMultiple(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  // 알림 보관
  Future<bool> archiveNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 기본 설정 생성
    final defaultTypeSettings = <NotificationType, bool>{};
    for (final type in NotificationType.values) {
      defaultTypeSettings[type] = true;
    }

    return NotificationSettings(
      userId: userId,
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
      typeSettings: defaultTypeSettings,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
      weekendEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  // 알림 설정 업데이트
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  // 푸시 알림 토큰 등록
  Future<bool> registerPushToken(String userId, String token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // 푸시 알림 토큰 해제
  Future<bool> unregisterPushToken(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // 테스트 알림 발송
  Future<bool> sendTestNotification(String userId, NotificationType type) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final testNotification = AppNotification(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      title: '테스트 알림',
      message: '알림이 정상적으로 작동합니다.',
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
    );

    // 실시간 알림 스트림으로 전송
    _emitTestNotification(testNotification);
    
    return true;
  }

  // 실시간 알림 시뮬레이션 시작
  void startRealTimeNotifications(String userId) {
    Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_random.nextBool()) {
        final notification = _generateRandomNotification(userId);
        _emitTestNotification(notification);
      }
    });
  }

  // 알림 통계 가져오기
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'total_count': _random.nextInt(100) + 50,
      'unread_count': _random.nextInt(10) + 1,
      'today_count': _random.nextInt(10) + 1,
      'this_week_count': _random.nextInt(30) + 10,
      'type_breakdown': {
        'contract': _random.nextInt(20) + 5,
        'payment': _random.nextInt(15) + 3,
        'message': _random.nextInt(25) + 8,
        'review': _random.nextInt(10) + 2,
        'system': _random.nextInt(5) + 1,
      },
    };
  }

  // 목업 알림 생성
  List<AppNotification> _generateMockNotifications(String userId, int count) {
    final notifications = <AppNotification>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final type = NotificationType.values[_random.nextInt(NotificationType.values.length)];
      final priority = NotificationPriority.values[_random.nextInt(NotificationPriority.values.length)];
      final status = _random.nextBool() ? NotificationStatus.unread : NotificationStatus.read;
      
      final notification = AppNotification(
        id: 'notification_$i',
        userId: userId,
        type: type,
        title: _getTitleForType(type),
        message: _getMessageForType(type),
        priority: priority,
        status: status,
        createdAt: now.subtract(Duration(
          hours: _random.nextInt(24 * 7), // 지난 일주일 내
          minutes: _random.nextInt(60),
        )),
        actions: _getActionsForType(type),
        data: {
          'contract_id': 'contract_${_random.nextInt(1000)}',
          'campaign_name': '샘플 캠페인 ${_random.nextInt(100)}',
          'amount': _random.nextInt(1000000) + 100000,
        },
      );

      notifications.add(notification);
    }

    return notifications;
  }

  AppNotification _generateRandomNotification(String userId) {
    final type = NotificationType.values[_random.nextInt(NotificationType.values.length)];
    
    return AppNotification(
      id: 'realtime_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      title: _getTitleForType(type),
      message: _getMessageForType(type),
      priority: NotificationPriority.values[_random.nextInt(NotificationPriority.values.length)],
      status: NotificationStatus.unread,
      createdAt: DateTime.now(),
      actions: _getActionsForType(type),
      data: {
        'contract_id': 'contract_${_random.nextInt(1000)}',
        'campaign_name': '새로운 캠페인 ${_random.nextInt(100)}',
        'amount': _random.nextInt(1000000) + 100000,
      },
    );
  }

  String _getTitleForType(NotificationType type) {
    switch (type) {
      case NotificationType.matchFound:
        return '새로운 매칭을 찾았습니다!';
      case NotificationType.matchAccepted:
        return '매칭이 수락되었습니다';
      case NotificationType.contractCreated:
        return '새로운 계약서가 도착했습니다';
      case NotificationType.contractSigned:
        return '계약서가 서명되었습니다';
      case NotificationType.paymentReceived:
        return '결제가 완료되었습니다';
      case NotificationType.newMessage:
        return '새로운 메시지가 도착했습니다';
      case NotificationType.reviewReceived:
        return '새로운 리뷰가 도착했습니다';
      case NotificationType.profileVerified:
        return '프로필 인증이 완료되었습니다';
      case NotificationType.campaignApproved:
        return '캠페인이 승인되었습니다';
      default:
        return '새로운 알림';
    }
  }

  String _getMessageForType(NotificationType type) {
    final campaigns = ['뷰티 제품 리뷰', '패션 브랜드 협업', '푸드 체험단', '여행 상품 홍보', '테크 제품 리뷰'];
    final campaign = campaigns[_random.nextInt(campaigns.length)];
    
    switch (type) {
      case NotificationType.matchFound:
        return '$campaign 캠페인에 적합한 인플루언서를 찾았습니다. 지금 확인해보세요!';
      case NotificationType.matchAccepted:
        return '$campaign 캠페인 매칭이 성사되었습니다. 계약 진행을 시작해주세요.';
      case NotificationType.contractCreated:
        return '$campaign 캠페인 계약서를 검토하고 서명해주세요.';
      case NotificationType.contractSigned:
        return '$campaign 캠페인 계약이 체결되었습니다. 이제 협업을 시작할 수 있습니다.';
      case NotificationType.paymentReceived:
        return '$campaign 캠페인 대금 ${(_random.nextInt(500) + 100)}만원이 입금되었습니다.';
      case NotificationType.newMessage:
        return '협업 파트너가 새로운 메시지를 보냈습니다.';
      case NotificationType.reviewReceived:
        return '${_random.nextInt(5) + 1}.0점의 리뷰를 받았습니다. 감사 인사를 전해보세요!';
      case NotificationType.profileVerified:
        return '프로필 인증이 완료되어 더 많은 캠페인에 참여할 수 있습니다.';
      case NotificationType.campaignApproved:
        return '$campaign 캠페인이 승인되었습니다. 이제 인플루언서 매칭을 시작합니다.';
      default:
        return '새로운 업데이트가 있습니다. 확인해보세요.';
    }
  }

  List<NotificationAction>? _getActionsForType(NotificationType type) {
    switch (type) {
      case NotificationType.matchFound:
        return [
          NotificationAction(
            id: 'view_match',
            label: '매칭 보기',
            route: '/match',
            isPrimary: true,
          ),
        ];
      case NotificationType.contractCreated:
        return [
          NotificationAction(
            id: 'view_contract',
            label: '계약서 보기',
            route: '/contract/list',
            isPrimary: true,
          ),
        ];
      case NotificationType.newMessage:
        return [
          NotificationAction(
            id: 'open_chat',
            label: '채팅 열기',
            route: '/chat',
            isPrimary: true,
          ),
        ];
      case NotificationType.reviewReceived:
        return [
          NotificationAction(
            id: 'view_review',
            label: '리뷰 보기',
            route: '/review/list',
            isPrimary: true,
          ),
        ];
      default:
        return null;
    }
  }

  void _emitTestNotification(AppNotification notification) {
    // 현재 알림 목록에 새 알림 추가 (실제 구현에서는 상태 관리)
    final currentNotifications = <AppNotification>[notification];
    _notificationsController.add(currentNotifications);
    
    // 읽지 않은 알림 수 업데이트
    _unreadCountController.add(1);
  }

  // 리소스 정리
  void dispose() {
    _notificationsController.close();
    _unreadCountController.close();
  }
}
