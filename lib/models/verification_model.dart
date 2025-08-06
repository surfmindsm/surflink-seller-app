import 'package:flutter/material.dart';
import 'file_upload_model.dart';

/// 인증 상태
enum VerificationStatus {
  notStarted,  // 인증 시작 안함
  pending,     // 인증 대기 중
  approved,    // 인증 승인
  rejected,    // 인증 거절
  expired,     // 인증 만료
}

/// 인증 타입
enum VerificationType {
  identity,      // 실명 인증
  business,      // 사업자 인증
  phone,         // 휴대폰 인증
  email,         // 이메일 인증
  sns,          // SNS 계정 인증
  portfolio,    // 포트폴리오 인증
  followers,    // 팔로워 수 인증
  address,      // 주소 인증
}

/// 인증 정보
class VerificationInfo {
  final VerificationType type;
  final VerificationStatus status;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final String? rejectReason;
  final List<UploadedFile>? documents;
  final Map<String, dynamic>? metadata;

  VerificationInfo({
    required this.type,
    required this.status,
    this.submittedAt,
    this.approvedAt,
    this.expiresAt,
    this.rejectReason,
    this.documents,
    this.metadata,
  });

  /// 인증 완료 여부
  bool get isVerified => status == VerificationStatus.approved;

  /// 인증 대기 중 여부
  bool get isPending => status == VerificationStatus.pending;

  /// 인증 거절 여부
  bool get isRejected => status == VerificationStatus.rejected;

  /// 인증 만료 여부
  bool get isExpired => status == VerificationStatus.expired;

  /// 인증 가능 여부
  bool get canVerify => status == VerificationStatus.notStarted || status == VerificationStatus.rejected;

  /// 인증 타입 이름
  String get typeName {
    switch (type) {
      case VerificationType.identity:
        return '실명 인증';
      case VerificationType.business:
        return '사업자 인증';
      case VerificationType.phone:
        return '휴대폰 인증';
      case VerificationType.email:
        return '이메일 인증';
      case VerificationType.sns:
        return 'SNS 인증';
      case VerificationType.portfolio:
        return '포트폴리오 인증';
      case VerificationType.followers:
        return '팔로워 인증';
      case VerificationType.address:
        return '주소 인증';
    }
  }

  /// 인증 상태 텍스트
  String get statusText {
    switch (status) {
      case VerificationStatus.notStarted:
        return '인증 전';
      case VerificationStatus.pending:
        return '인증 대기 중';
      case VerificationStatus.approved:
        return '인증 완료';
      case VerificationStatus.rejected:
        return '인증 거절';
      case VerificationStatus.expired:
        return '인증 만료';
    }
  }

  /// 인증 상태 색상
  Color get statusColor {
    switch (status) {
      case VerificationStatus.notStarted:
        return Colors.grey;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.expired:
        return Colors.red.shade300;
    }
  }

  /// 인증 상태 아이콘
  IconData get statusIcon {
    switch (status) {
      case VerificationStatus.notStarted:
        return Icons.help_outline;
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.approved:
        return Icons.verified;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.expired:
        return Icons.access_time;
    }
  }

  /// 복사본 생성
  VerificationInfo copyWith({
    VerificationType? type,
    VerificationStatus? status,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? expiresAt,
    String? rejectReason,
    List<UploadedFile>? documents,
    Map<String, dynamic>? metadata,
  }) {
    return VerificationInfo(
      type: type ?? this.type,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rejectReason: rejectReason ?? this.rejectReason,
      documents: documents ?? this.documents,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'status': status.name,
      'submitted_at': submittedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'reject_reason': rejectReason,
      'documents': documents?.map((doc) => doc.toJson()).toList(),
      'metadata': metadata,
    };
  }

  /// JSON 역직렬화
  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return VerificationInfo(
      type: VerificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VerificationType.identity,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.notStarted,
      ),
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at']) : null,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      rejectReason: json['reject_reason'],
      documents: json['documents'] != null
          ? (json['documents'] as List).map((doc) => UploadedFile.fromJson(doc)).toList()
          : null,
      metadata: json['metadata'],
    );
  }
}

/// 사용자 인증 상태
class UserVerificationStatus {
  final Map<VerificationType, VerificationInfo> verifications;
  final int verificationScore;
  final String verificationLevel;

  UserVerificationStatus({
    required this.verifications,
    required this.verificationScore,
    required this.verificationLevel,
  });

  /// 특정 인증 정보 가져오기
  VerificationInfo? getVerification(VerificationType type) {
    return verifications[type];
  }

  /// 인증 완료된 항목 수
  int get completedCount {
    return verifications.values.where((v) => v.isVerified).length;
  }

  /// 전체 인증 항목 수
  int get totalCount => verifications.length;

  /// 인증 완료율 (퍼센트)
  double get completionRate {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount) * 100;
  }

  /// 필수 인증 완료 여부
  bool get hasRequiredVerifications {
    final phoneVerification = getVerification(VerificationType.phone);
    final emailVerification = getVerification(VerificationType.email);
    
    return phoneVerification?.isVerified == true || emailVerification?.isVerified == true;
  }

  /// 신뢰도 높은 사용자 여부
  bool get isHighTrust {
    return verificationScore >= 80 && hasRequiredVerifications;
  }

  /// 인증 배지 목록
  List<VerificationBadge> get badges {
    List<VerificationBadge> badges = [];
    
    for (var verification in verifications.values) {
      if (verification.isVerified) {
        badges.add(VerificationBadge(
          type: verification.type,
          label: verification.typeName,
          color: verification.statusColor,
          icon: verification.statusIcon,
        ));
      }
    }
    
    return badges;
  }

  /// 복사본 생성
  UserVerificationStatus copyWith({
    Map<VerificationType, VerificationInfo>? verifications,
    int? verificationScore,
    String? verificationLevel,
  }) {
    return UserVerificationStatus(
      verifications: verifications ?? this.verifications,
      verificationScore: verificationScore ?? this.verificationScore,
      verificationLevel: verificationLevel ?? this.verificationLevel,
    );
  }

  /// 인증 정보 업데이트
  UserVerificationStatus updateVerification(VerificationType type, VerificationInfo info) {
    final newVerifications = Map<VerificationType, VerificationInfo>.from(verifications);
    newVerifications[type] = info;
    
    // 점수 재계산
    final newScore = _calculateVerificationScore(newVerifications);
    final newLevel = _calculateVerificationLevel(newScore);
    
    return copyWith(
      verifications: newVerifications,
      verificationScore: newScore,
      verificationLevel: newLevel,
    );
  }

  /// 인증 점수 계산
  int _calculateVerificationScore(Map<VerificationType, VerificationInfo> verifications) {
    int score = 0;
    
    for (var verification in verifications.values) {
      if (verification.isVerified) {
        switch (verification.type) {
          case VerificationType.identity:
            score += 25;
            break;
          case VerificationType.business:
            score += 20;
            break;
          case VerificationType.phone:
            score += 15;
            break;
          case VerificationType.email:
            score += 10;
            break;
          case VerificationType.sns:
            score += 10;
            break;
          case VerificationType.portfolio:
            score += 15;
            break;
          case VerificationType.followers:
            score += 10;
            break;
          case VerificationType.address:
            score += 5;
            break;
        }
      }
    }
    
    return score.clamp(0, 100);
  }

  /// 인증 레벨 계산
  String _calculateVerificationLevel(int score) {
    if (score >= 80) return '플래티넘';
    if (score >= 60) return '골드';
    if (score >= 40) return '실버';
    if (score >= 20) return '브론즈';
    return '뉴비';
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'verifications': verifications.map((key, value) => MapEntry(key.name, value.toJson())),
      'verification_score': verificationScore,
      'verification_level': verificationLevel,
    };
  }

  /// JSON 역직렬화
  factory UserVerificationStatus.fromJson(Map<String, dynamic> json) {
    Map<VerificationType, VerificationInfo> verifications = {};
    
    if (json['verifications'] != null) {
      (json['verifications'] as Map<String, dynamic>).forEach((key, value) {
        final type = VerificationType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => VerificationType.identity,
        );
        verifications[type] = VerificationInfo.fromJson(value);
      });
    }
    
    return UserVerificationStatus(
      verifications: verifications,
      verificationScore: json['verification_score'] ?? 0,
      verificationLevel: json['verification_level'] ?? '뉴비',
    );
  }
}

/// 인증 배지
class VerificationBadge {
  final VerificationType type;
  final String label;
  final Color color;
  final IconData icon;

  VerificationBadge({
    required this.type,
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// 인증 요청 데이터
class VerificationRequest {
  final VerificationType type;
  final Map<String, dynamic> data;
  final List<UploadedFile>? documents;
  final String? notes;

  VerificationRequest({
    required this.type,
    required this.data,
    this.documents,
    this.notes,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'documents': documents?.map((doc) => doc.toJson()).toList(),
      'notes': notes,
    };
  }
}
