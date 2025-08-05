import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // 알림 목록
  List<AppNotification>? _notifications;
  List<AppNotification>? get notifications => _notifications;

  // 읽지 않은 알림 수
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // 알림 설정
  NotificationSettings? _settings;
  NotificationSettings? get settings => _settings;

  // 알림 통계
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  // 로딩 상태
  bool _isLoadingNotifications = false;
  bool get isLoadingNotifications => _isLoadingNotifications;

  bool _isLoadingSettings = false;
  bool get isLoadingSettings => _isLoadingSettings;

  bool _isLoadingStats = false;
  bool get isLoadingStats => _isLoadingStats;

  // 에러 상태
  String? _notificationsError;
  String? get notificationsError => _notificationsError;

  String? _settingsError;
  String? get settingsError => _settingsError;

  String? _statsError;
  String? get statsError => _statsError;

  // 필터 및 정렬 옵션
  NotificationType? _typeFilter;
  NotificationType? get typeFilter => _typeFilter;

  NotificationStatus? _statusFilter;
  NotificationStatus? get statusFilter => _statusFilter;

  NotificationPriority? _priorityFilter;
  NotificationPriority? get priorityFilter => _priorityFilter;

  // 실시간 스트림 구독
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  NotificationProvider() {
    _initializeRealTimeNotifications();
  }

  void _initializeRealTimeNotifications() {
    // 실시간 알림 스트림 구독
    _notificationsSubscription = _notificationService.notificationsStream.listen(
      (newNotifications) {
        _handleRealTimeNotifications(newNotifications);
      },
    );

    // 읽지 않은 알림 수 스트림 구독
    _unreadCountSubscription = _notificationService.unreadCountStream.listen(
      (count) {
        _unreadCount += count;
        notifyListeners();
      },
    );
  }

  void _handleRealTimeNotifications(List<AppNotification> newNotifications) {
    if (_notifications != null) {
      // 기존 알림 목록에 새 알림 추가
      _notifications!.insertAll(0, newNotifications);
      
      // 중복 제거 (ID 기준)
      final uniqueNotifications = <String, AppNotification>{};
      for (final notification in _notifications!) {
        uniqueNotifications[notification.id] = notification;
      }
      _notifications = uniqueNotifications.values.toList();
      
      // 최신순 정렬
      _notifications!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    }
  }

  // 알림 목록 가져오기
  Future<void> loadNotifications({
    required String userId,
    bool refresh = false,
    int? limit,
    int? offset,
  }) async {
    if (!refresh && _notifications != null) return;

    _isLoadingNotifications = true;
    _notificationsError = null;
    notifyListeners();

    try {
      final notifications = await _notificationService.getNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
        type: _typeFilter,
        status: _statusFilter,
        priority: _priorityFilter,
      );

      if (refresh || offset == null || offset == 0) {
        _notifications = notifications;
      } else {
        // 페이지네이션: 기존 목록에 추가
        _notifications ??= [];
        _notifications!.addAll(notifications);
      }
    } catch (e) {
      _notificationsError = '알림을 불러오는데 실패했습니다: ${e.toString()}';
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  // 읽지 않은 알림 수 가져오기
  Future<void> loadUnreadCount(String userId) async {
    try {
      _unreadCount = await _notificationService.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('읽지 않은 알림 수 로딩 실패: $e');
    }
  }

  // 알림 읽음 처리
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      
      if (success && _notifications != null) {
        final index = _notifications!.indexWhere((n) => n.id == notificationId);
        if (index != -1 && _notifications![index].isUnread) {
          _notifications![index] = _notifications![index].copyWith(
            status: NotificationStatus.read,
            readAt: DateTime.now(),
          );
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('알림 읽음 처리 실패: $e');
      return false;
    }
  }

  // 여러 알림 읽음 처리
  Future<bool> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final success = await _notificationService.markMultipleAsRead(notificationIds);
      
      if (success && _notifications != null) {
        int markedCount = 0;
        for (int i = 0; i < _notifications!.length; i++) {
          if (notificationIds.contains(_notifications![i].id) && _notifications![i].isUnread) {
            _notifications![i] = _notifications![i].copyWith(
              status: NotificationStatus.read,
              readAt: DateTime.now(),
            );
            markedCount++;
          }
        }
        _unreadCount = (_unreadCount - markedCount).clamp(0, double.infinity).toInt();
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('여러 알림 읽음 처리 실패: $e');
      return false;
    }
  }

  // 모든 알림 읽음 처리
  Future<bool> markAllAsRead(String userId) async {
    try {
      final success = await _notificationService.markAllAsRead(userId);
      
      if (success && _notifications != null) {
        for (int i = 0; i < _notifications!.length; i++) {
          if (_notifications![i].isUnread) {
            _notifications![i] = _notifications![i].copyWith(
              status: NotificationStatus.read,
              readAt: DateTime.now(),
            );
          }
        }
        _unreadCount = 0;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('모든 알림 읽음 처리 실패: $e');
      return false;
    }
  }

  // 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success && _notifications != null) {
        final index = _notifications!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications![index];
          _notifications!.removeAt(index);
          if (notification.isUnread) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('알림 삭제 실패: $e');
      return false;
    }
  }

  // 여러 알림 삭제
  Future<bool> deleteMultiple(List<String> notificationIds) async {
    try {
      final success = await _notificationService.deleteMultiple(notificationIds);
      
      if (success && _notifications != null) {
        int deletedUnreadCount = 0;
        _notifications!.removeWhere((notification) {
          if (notificationIds.contains(notification.id)) {
            if (notification.isUnread) deletedUnreadCount++;
            return true;
          }
          return false;
        });
        _unreadCount = (_unreadCount - deletedUnreadCount).clamp(0, double.infinity).toInt();
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('여러 알림 삭제 실패: $e');
      return false;
    }
  }

  // 알림 보관
  Future<bool> archiveNotification(String notificationId) async {
    try {
      final success = await _notificationService.archiveNotification(notificationId);
      
      if (success && _notifications != null) {
        final index = _notifications!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications![index] = _notifications![index].copyWith(
            status: NotificationStatus.archived,
          );
          if (_notifications![index].isUnread) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('알림 보관 실패: $e');
      return false;
    }
  }

  // 알림 설정 가져오기
  Future<void> loadNotificationSettings(String userId) async {
    _isLoadingSettings = true;
    _settingsError = null;
    notifyListeners();

    try {
      _settings = await _notificationService.getNotificationSettings(userId);
    } catch (e) {
      _settingsError = '알림 설정을 불러오는데 실패했습니다: ${e.toString()}';
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  // 알림 설정 업데이트
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final success = await _notificationService.updateNotificationSettings(settings);
      
      if (success) {
        _settings = settings;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('알림 설정 업데이트 실패: $e');
      return false;
    }
  }

  // 알림 통계 가져오기
  Future<void> loadNotificationStats(String userId) async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await _notificationService.getNotificationStats(userId);
    } catch (e) {
      _statsError = '알림 통계를 불러오는데 실패했습니다: ${e.toString()}';
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // 테스트 알림 발송
  Future<bool> sendTestNotification(String userId, NotificationType type) async {
    try {
      return await _notificationService.sendTestNotification(userId, type);
    } catch (e) {
      debugPrint('테스트 알림 발송 실패: $e');
      return false;
    }
  }

  // 실시간 알림 시작
  void startRealTimeNotifications(String userId) {
    _notificationService.startRealTimeNotifications(userId);
  }

  // 필터 설정
  void setTypeFilter(NotificationType? type) {
    if (_typeFilter != type) {
      _typeFilter = type;
      _notifications = null; // 필터 변경 시 목록 초기화
      notifyListeners();
    }
  }

  void setStatusFilter(NotificationStatus? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      _notifications = null;
      notifyListeners();
    }
  }

  void setPriorityFilter(NotificationPriority? priority) {
    if (_priorityFilter != priority) {
      _priorityFilter = priority;
      _notifications = null;
      notifyListeners();
    }
  }

  void clearFilters() {
    _typeFilter = null;
    _statusFilter = null;
    _priorityFilter = null;
    _notifications = null;
    notifyListeners();
  }

  // 필터링된 알림 목록 가져오기
  List<AppNotification> getFilteredNotifications() {
    if (_notifications == null) return [];

    return _notifications!.where((notification) {
      if (_typeFilter != null && notification.type != _typeFilter) return false;
      if (_statusFilter != null && notification.status != _statusFilter) return false;
      if (_priorityFilter != null && notification.priority != _priorityFilter) return false;
      return true;
    }).toList();
  }

  // 타입별 알림 수 가져오기
  Map<NotificationType, int> getNotificationCountsByType() {
    if (_notifications == null) return {};

    final counts = <NotificationType, int>{};
    for (final notification in _notifications!) {
      counts[notification.type] = (counts[notification.type] ?? 0) + 1;
    }
    return counts;
  }

  // 우선순위별 알림 수 가져오기
  Map<NotificationPriority, int> getNotificationCountsByPriority() {
    if (_notifications == null) return {};

    final counts = <NotificationPriority, int>{};
    for (final notification in _notifications!) {
      counts[notification.priority] = (counts[notification.priority] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}
