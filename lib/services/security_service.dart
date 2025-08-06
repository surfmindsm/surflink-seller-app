import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/security_model.dart';

/// 보안 및 개인정보 관리 서비스
class SecurityService {
  static const String _securitySettingsKey = 'security_settings';
  
  /// 보안 설정 조회
  Future<SecuritySettings?> getSecuritySettings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('${_securitySettingsKey}_$userId');
    
    if (settingsJson != null) {
      return SecuritySettings.fromJson(json.decode(settingsJson));
    }
    
    // 기본 설정 생성
    return _createDefaultSecuritySettings(userId);
  }

  /// 보안 설정 저장
  Future<bool> saveSecuritySettings(SecuritySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());
      await prefs.setString('${_securitySettingsKey}_${settings.userId}', settingsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 2차 인증 활성화/비활성화
  Future<bool> toggleTwoFactorAuth(String userId, bool enable) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 목업: 50% 확률로 성공
    final success = Random().nextBool();
    
    if (success) {
      final settings = await getSecuritySettings(userId);
      if (settings != null) {
        final updatedSettings = settings.copyWith(isTwoFactorEnabled: enable);
        await saveSecuritySettings(updatedSettings);
      }
    }
    
    return success;
  }

  /// SMS 인증 코드 전송
  Future<bool> sendSmsVerificationCode(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // 목업: 90% 확률로 성공
    return Random().nextInt(10) < 9;
  }

  /// 이메일 인증 코드 전송
  Future<bool> sendEmailVerificationCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 목업: 95% 확률로 성공
    return Random().nextInt(20) < 19;
  }

  /// 인증 코드 확인
  Future<bool> verifyCode(String code, String type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 목업: 코드가 "123456"이면 항상 성공
    if (code == "123456") return true;
    
    // 그 외에는 80% 확률로 성공
    return Random().nextInt(10) < 8;
  }

  /// 비밀번호 변경
  Future<bool> changePassword(String userId, ChangePasswordRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // 유효성 검사
    final validationError = request.validationError;
    if (validationError != null) {
      throw Exception(validationError);
    }
    
    // 목업: 현재 비밀번호가 "password123"이면 성공
    if (request.currentPassword != "password123") {
      throw Exception('현재 비밀번호가 올바르지 않습니다.');
    }
    
    // 보안 설정 업데이트
    final settings = await getSecuritySettings(userId);
    if (settings != null) {
      final updatedSettings = settings.copyWith(
        lastPasswordChanged: DateTime.now(),
      );
      await saveSecuritySettings(updatedSettings);
    }
    
    return true;
  }

  /// 로그인 기록 조회
  Future<List<LoginHistory>> getLoginHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _generateMockLoginHistory(userId);
  }

  /// 로그인 기기 목록 조회
  Future<List<LoginDevice>> getLoginDevices(String userId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    
    return _generateMockLoginDevices(userId);
  }

  /// 기기 신뢰 설정
  Future<bool> setDeviceTrust(String userId, String deviceId, bool trusted) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 목업: 항상 성공
    return true;
  }

  /// 기기 로그아웃
  Future<bool> logoutDevice(String userId, String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 목업: 현재 기기가 아니면 성공
    final devices = await getLoginDevices(userId);
    final device = devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => LoginDevice(
        id: '',
        deviceName: '',
        deviceType: '',
        osVersion: '',
        appVersion: '',
        location: '',
        firstLogin: DateTime.now(),
        lastLogin: DateTime.now(),
      ),
    );
    
    return !device.isCurrentDevice;
  }

  /// 알림 설정 업데이트
  Future<bool> updateNotificationSettings(String userId, NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    try {
      final securitySettings = await getSecuritySettings(userId);
      if (securitySettings != null) {
        final updatedSettings = securitySettings.copyWith(
          notificationSettings: settings,
        );
        await saveSecuritySettings(updatedSettings);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 개인정보 설정 업데이트
  Future<bool> updatePrivacySettings(String userId, PrivacySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 450));
    
    try {
      final securitySettings = await getSecuritySettings(userId);
      if (securitySettings != null) {
        final updatedSettings = securitySettings.copyWith(
          privacySettings: settings,
        );
        await saveSecuritySettings(updatedSettings);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 계정 삭제
  Future<bool> deleteAccount(String userId, DeleteAccountRequest request) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // 비밀번호 확인
    if (request.password != "password123") {
      throw Exception('비밀번호가 올바르지 않습니다.');
    }
    
    // 목업: 항상 성공 (실제로는 백엔드에서 처리)
    return true;
  }

  /// 사용자 차단
  Future<bool> blockUser(String userId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final settings = await getSecuritySettings(userId);
    if (settings != null) {
      final blockedUsers = List<String>.from(settings.privacySettings.blockedUsers);
      if (!blockedUsers.contains(targetUserId)) {
        blockedUsers.add(targetUserId);
        
        final updatedPrivacySettings = settings.privacySettings.copyWith(
          blockedUsers: blockedUsers,
        );
        
        final updatedSettings = settings.copyWith(
          privacySettings: updatedPrivacySettings,
        );
        
        await saveSecuritySettings(updatedSettings);
      }
    }
    
    return true;
  }

  /// 사용자 차단 해제
  Future<bool> unblockUser(String userId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final settings = await getSecuritySettings(userId);
    if (settings != null) {
      final blockedUsers = List<String>.from(settings.privacySettings.blockedUsers);
      blockedUsers.remove(targetUserId);
      
      final updatedPrivacySettings = settings.privacySettings.copyWith(
        blockedUsers: blockedUsers,
      );
      
      final updatedSettings = settings.copyWith(
        privacySettings: updatedPrivacySettings,
      );
      
      await saveSecuritySettings(updatedSettings);
    }
    
    return true;
  }

  /// 기본 보안 설정 생성
  SecuritySettings _createDefaultSecuritySettings(String userId) {
    return SecuritySettings(
      userId: userId,
      isTwoFactorEnabled: false,
      isBiometricEnabled: false,
      phoneNumber: '+82-10-1234-5678',
      email: 'user@example.com',
      isPhoneVerified: true,
      isEmailVerified: false,
      lastPasswordChanged: DateTime.now().subtract(const Duration(days: 45)),
      devices: _generateMockLoginDevices(userId),
      loginHistory: _generateMockLoginHistory(userId),
      notificationSettings: const NotificationSettings(
        enablePushNotifications: true,
        enableEmailNotifications: true,
        enableSmsNotifications: false,
        notificationTypes: {
          'campaign': true,
          'match': true,
          'message': true,
          'review': true,
          'payment': true,
          'marketing': false,
        },
        quietHours: QuietHours(
          enabled: true,
          startHour: 22,
          startMinute: 0,
          endHour: 8,
          endMinute: 0,
          weekdays: [0, 1, 2, 3, 4, 5, 6],
        ),
      ),
      privacySettings: const PrivacySettings(
        showOnlineStatus: true,
        showLastSeen: true,
        showPhoneNumber: false,
        showEmail: false,
        allowSearchByPhone: false,
        allowSearchByEmail: false,
        profileVisibility: ProfileVisibility.public,
        blockedUsers: [],
      ),
    );
  }

  /// 목업 로그인 기록 생성
  List<LoginHistory> _generateMockLoginHistory(String userId) {
    final random = Random();
    final now = DateTime.now();
    
    return List.generate(10, (index) {
      final loginTime = now.subtract(Duration(
        days: random.nextInt(30),
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      ));
      
      final devices = ['iPhone 13', 'Galaxy S22', 'MacBook Pro', 'Windows PC', 'iPad'];
      final locations = ['서울', '부산', '대구', '인천', '광주'];
      final ips = ['192.168.1.100', '10.0.0.50', '172.16.0.20'];
      
      return LoginHistory(
        id: 'history_${userId}_$index',
        loginTime: loginTime,
        deviceInfo: devices[random.nextInt(devices.length)],
        location: locations[random.nextInt(locations.length)],
        ipAddress: ips[random.nextInt(ips.length)],
        status: random.nextInt(10) < 9 ? LoginStatus.success : LoginStatus.failed,
        failureReason: random.nextInt(10) < 9 ? null : '잘못된 비밀번호',
      );
    });
  }

  /// 목업 로그인 기기 생성
  List<LoginDevice> _generateMockLoginDevices(String userId) {
    final random = Random();
    final now = DateTime.now();
    
    return [
      LoginDevice(
        id: 'device_${userId}_current',
        deviceName: 'iPhone 13 Pro',
        deviceType: 'Mobile',
        osVersion: 'iOS 16.1',
        appVersion: '1.0.0',
        location: '서울, 대한민국',
        firstLogin: now.subtract(const Duration(days: 30)),
        lastLogin: now,
        isTrusted: true,
        isCurrentDevice: true,
      ),
      LoginDevice(
        id: 'device_${userId}_web',
        deviceName: 'MacBook Pro',
        deviceType: 'Desktop',
        osVersion: 'macOS 13.0',
        appVersion: 'Web 1.0.0',
        location: '서울, 대한민국',
        firstLogin: now.subtract(const Duration(days: 15)),
        lastLogin: now.subtract(const Duration(hours: 2)),
        isTrusted: true,
        isCurrentDevice: false,
      ),
      LoginDevice(
        id: 'device_${userId}_old',
        deviceName: 'Galaxy S21',
        deviceType: 'Mobile',
        osVersion: 'Android 12',
        appVersion: '0.9.5',
        location: '부산, 대한민국',
        firstLogin: now.subtract(const Duration(days: 90)),
        lastLogin: now.subtract(const Duration(days: 7)),
        isTrusted: false,
        isCurrentDevice: false,
      ),
    ];
  }
}

/// 보안 상태 체크 서비스
class SecurityStatusService {
  static Future<List<SecurityRecommendation>> getSecurityRecommendations(
    SecuritySettings settings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final recommendations = <SecurityRecommendation>[];
    
    // 2차 인증
    if (!settings.isTwoFactorEnabled) {
      recommendations.add(const SecurityRecommendation(
        type: RecommendationType.twoFactor,
        title: '2차 인증 활성화',
        description: '계정 보안을 크게 향상시킬 수 있습니다.',
        priority: RecommendationPriority.high,
        iconData: 'security',
      ));
    }
    
    // 생체 인증
    if (!settings.isBiometricEnabled) {
      recommendations.add(const SecurityRecommendation(
        type: RecommendationType.biometric,
        title: '생체 인증 활성화',
        description: '지문이나 얼굴 인식으로 편리하게 로그인하세요.',
        priority: RecommendationPriority.medium,
        iconData: 'fingerprint',
      ));
    }
    
    // 비밀번호 변경
    if (settings.lastPasswordChanged != null) {
      final daysSinceChange = DateTime.now().difference(settings.lastPasswordChanged!).inDays;
      if (daysSinceChange > 90) {
        recommendations.add(const SecurityRecommendation(
          type: RecommendationType.passwordChange,
          title: '비밀번호 변경',
          description: '3개월 이상 비밀번호를 변경하지 않았습니다.',
          priority: RecommendationPriority.medium,
          iconData: 'lock',
        ));
      }
    }
    
    // 이메일 인증
    if (!settings.isEmailVerified) {
      recommendations.add(const SecurityRecommendation(
        type: RecommendationType.emailVerification,
        title: '이메일 인증',
        description: '계정 복구를 위해 이메일을 인증해주세요.',
        priority: RecommendationPriority.low,
        iconData: 'email',
      ));
    }
    
    return recommendations;
  }
}

/// 보안 권장사항
class SecurityRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final String iconData;

  const SecurityRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.iconData,
  });
}

/// 권장사항 타입
enum RecommendationType {
  twoFactor,
  biometric,
  passwordChange,
  emailVerification,
  phoneVerification,
}

/// 권장사항 우선순위
enum RecommendationPriority {
  low('낮음'),
  medium('보통'),
  high('높음');

  const RecommendationPriority(this.label);
  
  final String label;
}
