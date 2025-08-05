import 'package:flutter/material.dart';

// 알림 타입
enum NotificationType {
  // 매칭 관련
  matchFound,        // 매칭 발견
  matchAccepted,     // 매칭 수락
  matchRejected,     // 매칭 거부
  
  // 계약 관련
  contractCreated,   // 계약서 생성
  contractSigned,    // 계약서 서명
  contractCompleted, // 계약 완료
  contractCancelled, // 계약 취소
  
  // 결제 관련
  paymentReceived,   // 결제 완료
  paymentFailed,     // 결제 실패
  paymentRefunded,   // 환불 완료
  
  // 채팅 관련
  newMessage,        // 새 메시지
  
  // 리뷰 관련
  reviewReceived,    // 리뷰 받음
  reviewReply,       // 리뷰 답글
  
  // 시스템 알림
  systemUpdate,      // 시스템 업데이트
  maintenance,       // 시스템 점검
  promotion,         // 프로모션
  announcement,      // 공지사항
  
  // 계정 관련
  profileVerified,   // 프로필 인증 완료
  profileRejected,   // 프로필 인증 거부
  
  // 캠페인 관련
  campaignApproved,  // 캠페인 승인
  campaignRejected,  // 캠페인 거부
  campaignExpiring,  // 캠페인 만료 임박
}

// 알림 우선순위
enum NotificationPriority {
  low,    // 낮음 (일반적인 정보)
  normal, // 보통 (기본값)
  high,   // 높음 (중요한 업데이트)
  urgent, // 긴급 (즉시 확인 필요)
}

// 알림 상태
enum NotificationStatus {
  unread,  // 읽지 않음
  read,    // 읽음
  archived, // 보관됨
}

// 알림 액션
class NotificationAction {
  final String id;
  final String label;
  final String route;
  final Map<String, String>? params;
  final bool isPrimary;

  NotificationAction({
    required this.id,
    required this.label,
    required this.route,
    this.params,
    this.isPrimary = false,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) => NotificationAction(
        id: json['id'],
        label: json['label'],
        route: json['route'],
        params: json['params'] != null
            ? Map<String, String>.from(json['params'])
            : null,
        isPrimary: json['is_primary'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'route': route,
        'params': params,
        'is_primary': isPrimary,
      };
}

// 알림
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final Map<String, dynamic>? data; // 추가 데이터
  final List<NotificationAction>? actions;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt; // 만료 시간

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.data,
    this.actions,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.unread,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
  });

  String get typeDisplayName {
    switch (type) {
      case NotificationType.matchFound:
        return '매칭 발견';
      case NotificationType.matchAccepted:
        return '매칭 수락';
      case NotificationType.matchRejected:
        return '매칭 거부';
      case NotificationType.contractCreated:
        return '계약서 생성';
      case NotificationType.contractSigned:
        return '계약서 서명';
      case NotificationType.contractCompleted:
        return '계약 완료';
      case NotificationType.contractCancelled:
        return '계약 취소';
      case NotificationType.paymentReceived:
        return '결제 완료';
      case NotificationType.paymentFailed:
        return '결제 실패';
      case NotificationType.paymentRefunded:
        return '환불 완료';
      case NotificationType.newMessage:
        return '새 메시지';
      case NotificationType.reviewReceived:
        return '리뷰 받음';
      case NotificationType.reviewReply:
        return '리뷰 답글';
      case NotificationType.systemUpdate:
        return '시스템 업데이트';
      case NotificationType.maintenance:
        return '시스템 점검';
      case NotificationType.promotion:
        return '프로모션';
      case NotificationType.announcement:
        return '공지사항';
      case NotificationType.profileVerified:
        return '프로필 인증 완료';
      case NotificationType.profileRejected:
        return '프로필 인증 거부';
      case NotificationType.campaignApproved:
        return '캠페인 승인';
      case NotificationType.campaignRejected:
        return '캠페인 거부';
      case NotificationType.campaignExpiring:
        return '캠페인 만료 임박';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.matchFound:
      case NotificationType.matchAccepted:
        return Icons.favorite;
      case NotificationType.matchRejected:
        return Icons.favorite_border;
      case NotificationType.contractCreated:
      case NotificationType.contractSigned:
      case NotificationType.contractCompleted:
        return Icons.description;
      case NotificationType.contractCancelled:
        return Icons.cancel;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.paymentFailed:
        return Icons.error;
      case NotificationType.paymentRefunded:
        return Icons.money_off;
      case NotificationType.newMessage:
        return Icons.chat;
      case NotificationType.reviewReceived:
      case NotificationType.reviewReply:
        return Icons.star;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.announcement:
        return Icons.announcement;
      case NotificationType.profileVerified:
        return Icons.verified;
      case NotificationType.profileRejected:
        return Icons.error_outline;
      case NotificationType.campaignApproved:
        return Icons.check_circle;
      case NotificationType.campaignRejected:
        return Icons.cancel;
      case NotificationType.campaignExpiring:
        return Icons.schedule;
    }
  }

  Color get typeColor {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  Color get statusColor {
    switch (status) {
      case NotificationStatus.unread:
        return Colors.blue;
      case NotificationStatus.read:
        return Colors.grey;
      case NotificationStatus.archived:
        return Colors.grey.withOpacity(0.5);
    }
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isUnread => status == NotificationStatus.unread;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        userId: json['user_id'],
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.announcement,
        ),
        title: json['title'],
        message: json['message'],
        imageUrl: json['image_url'],
        data: json['data'],
        actions: json['actions'] != null
            ? (json['actions'] as List)
                .map((action) => NotificationAction.fromJson(action))
                .toList()
            : null,
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => NotificationPriority.normal,
        ),
        status: NotificationStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => NotificationStatus.unread,
        ),
        createdAt: DateTime.parse(json['created_at']),
        readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
        expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'title': title,
        'message': message,
        'image_url': imageUrl,
        'data': data,
        'actions': actions?.map((action) => action.toJson()).toList(),
        'priority': priority.name,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      };

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? imageUrl,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

// 알림 설정
class NotificationSettings {
  final String userId;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final Map<NotificationType, bool> typeSettings;
  final String? quietHoursStart; // "22:00" 형식
  final String? quietHoursEnd;   // "08:00" 형식
  final bool weekendEnabled;
  final DateTime updatedAt;

  NotificationSettings({
    required this.userId,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    required this.typeSettings,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.weekendEnabled = true,
    required this.updatedAt,
  });

  bool isTypeEnabled(NotificationType type) {
    return typeSettings[type] ?? true;
  }

  bool get hasQuietHours {
    return quietHoursStart != null && quietHoursEnd != null;
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
        userId: json['user_id'],
        pushEnabled: json['push_enabled'] ?? true,
        emailEnabled: json['email_enabled'] ?? true,
        smsEnabled: json['sms_enabled'] ?? false,
        typeSettings: (json['type_settings'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(
                  NotificationType.values.firstWhere((e) => e.name == key),
                  value as bool,
                )),
        quietHoursStart: json['quiet_hours_start'],
        quietHoursEnd: json['quiet_hours_end'],
        weekendEnabled: json['weekend_enabled'] ?? true,
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'push_enabled': pushEnabled,
        'email_enabled': emailEnabled,
        'sms_enabled': smsEnabled,
        'type_settings': typeSettings.map((key, value) => MapEntry(key.name, value)),
        'quiet_hours_start': quietHoursStart,
        'quiet_hours_end': quietHoursEnd,
        'weekend_enabled': weekendEnabled,
        'updated_at': updatedAt.toIso8601String(),
      };
}
