/// 보안 및 개인정보 설정 관련 모델

/// 보안 설정 정보
class SecuritySettings {
  final String userId;
  final bool isTwoFactorEnabled;
  final bool isBiometricEnabled;
  final String phoneNumber;
  final String email;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final DateTime? lastPasswordChanged;
  final List<LoginDevice> devices;
  final List<LoginHistory> loginHistory;
  final NotificationSettings notificationSettings;
  final PrivacySettings privacySettings;

  const SecuritySettings({
    required this.userId,
    this.isTwoFactorEnabled = false,
    this.isBiometricEnabled = false,
    this.phoneNumber = '',
    this.email = '',
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.lastPasswordChanged,
    this.devices = const [],
    this.loginHistory = const [],
    required this.notificationSettings,
    required this.privacySettings,
  });

  SecuritySettings copyWith({
    String? userId,
    bool? isTwoFactorEnabled,
    bool? isBiometricEnabled,
    String? phoneNumber,
    String? email,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    DateTime? lastPasswordChanged,
    List<LoginDevice>? devices,
    List<LoginHistory>? loginHistory,
    NotificationSettings? notificationSettings,
    PrivacySettings? privacySettings,
  }) {
    return SecuritySettings(
      userId: userId ?? this.userId,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastPasswordChanged: lastPasswordChanged ?? this.lastPasswordChanged,
      devices: devices ?? this.devices,
      loginHistory: loginHistory ?? this.loginHistory,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

  /// 보안 강도 계산 (0-100)
  int get securityScore {
    int score = 0;
    
    // 2차 인증 (+30점)
    if (isTwoFactorEnabled) score += 30;
    
    // 생체 인증 (+20점)
    if (isBiometricEnabled) score += 20;
    
    // 전화번호 인증 (+15점)
    if (isPhoneVerified) score += 15;
    
    // 이메일 인증 (+15점)
    if (isEmailVerified) score += 15;
    
    // 최근 비밀번호 변경 (+20점)
    if (lastPasswordChanged != null) {
      final daysSince = DateTime.now().difference(lastPasswordChanged!).inDays;
      if (daysSince <= 90) score += 20;
      else if (daysSince <= 180) score += 10;
    }
    
    return score.clamp(0, 100);
  }

  /// 보안 강도 레벨
  SecurityLevel get securityLevel {
    final score = securityScore;
    if (score >= 80) return SecurityLevel.high;
    if (score >= 50) return SecurityLevel.medium;
    if (score >= 25) return SecurityLevel.low;
    return SecurityLevel.veryLow;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'isBiometricEnabled': isBiometricEnabled,
      'phoneNumber': phoneNumber,
      'email': email,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'lastPasswordChanged': lastPasswordChanged?.toIso8601String(),
      'devices': devices.map((d) => d.toJson()).toList(),
      'loginHistory': loginHistory.map((h) => h.toJson()).toList(),
      'notificationSettings': notificationSettings.toJson(),
      'privacySettings': privacySettings.toJson(),
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      userId: json['userId'] ?? '',
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastPasswordChanged: json['lastPasswordChanged'] != null 
          ? DateTime.parse(json['lastPasswordChanged']) 
          : null,
      devices: (json['devices'] as List? ?? [])
          .map((d) => LoginDevice.fromJson(d))
          .toList(),
      loginHistory: (json['loginHistory'] as List? ?? [])
          .map((h) => LoginHistory.fromJson(h))
          .toList(),
      notificationSettings: NotificationSettings.fromJson(
          json['notificationSettings'] ?? {}),
      privacySettings: PrivacySettings.fromJson(
          json['privacySettings'] ?? {}),
    );
  }
}

/// 보안 레벨
enum SecurityLevel {
  veryLow('매우 낮음', 0),
  low('낮음', 25),
  medium('보통', 50),
  high('높음', 80);

  const SecurityLevel(this.label, this.threshold);
  
  final String label;
  final int threshold;
}

/// 로그인 기기 정보
class LoginDevice {
  final String id;
  final String deviceName;
  final String deviceType;
  final String osVersion;
  final String appVersion;
  final String location;
  final DateTime firstLogin;
  final DateTime lastLogin;
  final bool isTrusted;
  final bool isCurrentDevice;

  const LoginDevice({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.osVersion,
    required this.appVersion,
    required this.location,
    required this.firstLogin,
    required this.lastLogin,
    this.isTrusted = false,
    this.isCurrentDevice = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'location': location,
      'firstLogin': firstLogin.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isTrusted': isTrusted,
      'isCurrentDevice': isCurrentDevice,
    };
  }

  factory LoginDevice.fromJson(Map<String, dynamic> json) {
    return LoginDevice(
      id: json['id'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceType: json['deviceType'] ?? '',
      osVersion: json['osVersion'] ?? '',
      appVersion: json['appVersion'] ?? '',
      location: json['location'] ?? '',
      firstLogin: DateTime.parse(json['firstLogin']),
      lastLogin: DateTime.parse(json['lastLogin']),
      isTrusted: json['isTrusted'] ?? false,
      isCurrentDevice: json['isCurrentDevice'] ?? false,
    );
  }
}

/// 로그인 기록
class LoginHistory {
  final String id;
  final DateTime loginTime;
  final String deviceInfo;
  final String location;
  final String ipAddress;
  final LoginStatus status;
  final String? failureReason;

  const LoginHistory({
    required this.id,
    required this.loginTime,
    required this.deviceInfo,
    required this.location,
    required this.ipAddress,
    required this.status,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginTime': loginTime.toIso8601String(),
      'deviceInfo': deviceInfo,
      'location': location,
      'ipAddress': ipAddress,
      'status': status.name,
      'failureReason': failureReason,
    };
  }

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      id: json['id'] ?? '',
      loginTime: DateTime.parse(json['loginTime']),
      deviceInfo: json['deviceInfo'] ?? '',
      location: json['location'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      status: LoginStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => LoginStatus.success,
      ),
      failureReason: json['failureReason'],
    );
  }
}

/// 로그인 상태
enum LoginStatus {
  success('성공'),
  failed('실패'),
  blocked('차단됨');

  const LoginStatus(this.label);
  
  final String label;
}

/// 알림 설정
class NotificationSettings {
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableSmsNotifications;
  final Map<String, bool> notificationTypes;
  final QuietHours? quietHours;
  final bool vibrate;
  final String soundType;

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableSmsNotifications = false,
    this.notificationTypes = const {},
    this.quietHours,
    this.vibrate = true,
    this.soundType = 'default',
  });

  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableEmailNotifications,
    bool? enableSmsNotifications,
    Map<String, bool>? notificationTypes,
    QuietHours? quietHours,
    bool? vibrate,
    String? soundType,
  }) {
    return NotificationSettings(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      enableSmsNotifications: enableSmsNotifications ?? this.enableSmsNotifications,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      quietHours: quietHours ?? this.quietHours,
      vibrate: vibrate ?? this.vibrate,
      soundType: soundType ?? this.soundType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableSmsNotifications': enableSmsNotifications,
      'notificationTypes': notificationTypes,
      'quietHours': quietHours?.toJson(),
      'vibrate': vibrate,
      'soundType': soundType,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableEmailNotifications: json['enableEmailNotifications'] ?? true,
      enableSmsNotifications: json['enableSmsNotifications'] ?? false,
      notificationTypes: Map<String, bool>.from(json['notificationTypes'] ?? {}),
      quietHours: json['quietHours'] != null 
          ? QuietHours.fromJson(json['quietHours']) 
          : null,
      vibrate: json['vibrate'] ?? true,
      soundType: json['soundType'] ?? 'default',
    );
  }
}

/// 조용한 시간
class QuietHours {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> weekdays; // 0=일요일, 6=토요일

  const QuietHours({
    this.enabled = false,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 8,
    this.endMinute = 0,
    this.weekdays = const [0, 1, 2, 3, 4, 5, 6],
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'weekdays': weekdays,
    };
  }

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] ?? false,
      startHour: json['startHour'] ?? 22,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 8,
      endMinute: json['endMinute'] ?? 0,
      weekdays: List<int>.from(json['weekdays'] ?? [0, 1, 2, 3, 4, 5, 6]),
    );
  }

  /// 현재 조용한 시간 여부
  bool get isQuietNow {
    if (!enabled) return false;
    
    final now = DateTime.now();
    if (!weekdays.contains(now.weekday % 7)) return false;
    
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }
}

/// 개인정보 설정
class PrivacySettings {
  final bool showOnlineStatus;
  final bool showLastSeen;
  final bool showPhoneNumber;
  final bool showEmail;
  final bool allowSearchByPhone;
  final bool allowSearchByEmail;
  final bool dataProcessingConsent;
  final bool marketingConsent;
  final ProfileVisibility profileVisibility;
  final List<String> blockedUsers;

  const PrivacySettings({
    this.showOnlineStatus = true,
    this.showLastSeen = true,
    this.showPhoneNumber = false,
    this.showEmail = false,
    this.allowSearchByPhone = false,
    this.allowSearchByEmail = false,
    this.dataProcessingConsent = true,
    this.marketingConsent = false,
    this.profileVisibility = ProfileVisibility.public,
    this.blockedUsers = const [],
  });

  PrivacySettings copyWith({
    bool? showOnlineStatus,
    bool? showLastSeen,
    bool? showPhoneNumber,
    bool? showEmail,
    bool? allowSearchByPhone,
    bool? allowSearchByEmail,
    bool? dataProcessingConsent,
    bool? marketingConsent,
    ProfileVisibility? profileVisibility,
    List<String>? blockedUsers,
  }) {
    return PrivacySettings(
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showEmail: showEmail ?? this.showEmail,
      allowSearchByPhone: allowSearchByPhone ?? this.allowSearchByPhone,
      allowSearchByEmail: allowSearchByEmail ?? this.allowSearchByEmail,
      dataProcessingConsent: dataProcessingConsent ?? this.dataProcessingConsent,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showOnlineStatus': showOnlineStatus,
      'showLastSeen': showLastSeen,
      'showPhoneNumber': showPhoneNumber,
      'showEmail': showEmail,
      'allowSearchByPhone': allowSearchByPhone,
      'allowSearchByEmail': allowSearchByEmail,
      'dataProcessingConsent': dataProcessingConsent,
      'marketingConsent': marketingConsent,
      'profileVisibility': profileVisibility.name,
      'blockedUsers': blockedUsers,
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      showLastSeen: json['showLastSeen'] ?? true,
      showPhoneNumber: json['showPhoneNumber'] ?? false,
      showEmail: json['showEmail'] ?? false,
      allowSearchByPhone: json['allowSearchByPhone'] ?? false,
      allowSearchByEmail: json['allowSearchByEmail'] ?? false,
      dataProcessingConsent: json['dataProcessingConsent'] ?? true,
      marketingConsent: json['marketingConsent'] ?? false,
      profileVisibility: ProfileVisibility.values.firstWhere(
        (v) => v.name == json['profileVisibility'],
        orElse: () => ProfileVisibility.public,
      ),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
    );
  }
}

/// 프로필 공개 범위
enum ProfileVisibility {
  public('전체 공개'),
  private('비공개'),
  friendsOnly('친구만');

  const ProfileVisibility(this.label);
  
  final String label;
}

/// 비밀번호 변경 요청
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  /// 유효성 검사
  String? get validationError {
    if (currentPassword.isEmpty) {
      return '현재 비밀번호를 입력해주세요.';
    }
    
    if (newPassword.isEmpty) {
      return '새 비밀번호를 입력해주세요.';
    }
    
    if (newPassword.length < 8) {
      return '새 비밀번호는 8자 이상이어야 합니다.';
    }
    
    if (newPassword != confirmPassword) {
      return '새 비밀번호 확인이 일치하지 않습니다.';
    }
    
    if (currentPassword == newPassword) {
      return '현재 비밀번호와 새 비밀번호가 같습니다.';
    }
    
    // 비밀번호 강도 검사
    if (!_isStrongPassword(newPassword)) {
      return '비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다.';
    }
    
    return null;
  }

  /// 비밀번호 강도 검사
  bool _isStrongPassword(String password) {
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialChars;
  }
}

/// 계정 삭제 요청
class DeleteAccountRequest {
  final String password;
  final String reason;
  final bool deleteAllData;
  final bool keepDataForLegal;

  const DeleteAccountRequest({
    required this.password,
    required this.reason,
    this.deleteAllData = true,
    this.keepDataForLegal = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'reason': reason,
      'deleteAllData': deleteAllData,
      'keepDataForLegal': keepDataForLegal,
    };
  }
}
