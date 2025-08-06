import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/admin_model.dart';

/// 관리자 백오피스 서비스 (목업 구현)
class AdminService {
  
  /// 관리자 대시보드 통계 조회
  Future<AdminDashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    final now = DateTime.now();
    
    // 목업 일일 통계 생성 (최근 30일)
    final dailyStats = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return DailyStats(
        date: date,
        newUsers: random.nextInt(50) + 10,
        newCampaigns: random.nextInt(20) + 5,
        revenue: (random.nextDouble() * 1000000) + 100000,
      );
    });
    
    // 목업 카테고리별 통계
    final categories = ['뷰티', '패션', '라이프스타일', '푸드', '여행', '테크'];
    final categoryStats = categories.map((category) => CategoryStats(
      category: category,
      campaignCount: random.nextInt(100) + 20,
      revenue: (random.nextDouble() * 5000000) + 500000,
      averageRating: 3.5 + random.nextDouble() * 1.5,
    )).toList();
    
    return AdminDashboardStats(
      totalUsers: 15420 + random.nextInt(100),
      activeUsers: 8940 + random.nextInt(50),
      totalCampaigns: 3250 + random.nextInt(20),
      activeCampaigns: 245 + random.nextInt(10),
      pendingVerifications: 28 + random.nextInt(5),
      pendingReports: 12 + random.nextInt(3),
      totalRevenue: 125000000 + random.nextDouble() * 10000000,
      monthlyRevenue: 8500000 + random.nextDouble() * 1000000,
      dailyStats: dailyStats,
      categoryStats: categoryStats,
    );
  }

  /// 사용자 목록 조회
  Future<List<AdminUserInfo>> getUsers({
    int page = 1,
    int limit = 20,
    UserType? type,
    UserStatus? status,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final random = Random();
    final users = <AdminUserInfo>[];
    
    for (int i = 0; i < limit; i++) {
      final userType = type ?? (random.nextBool() ? UserType.influencer : UserType.seller);
      final userStatus = status ?? UserStatus.values[random.nextInt(UserStatus.values.length)];
      
      users.add(AdminUserInfo(
        id: 'user_${page}_$i',
        name: '사용자${(page - 1) * limit + i + 1}',
        email: 'user${(page - 1) * limit + i + 1}@example.com',
        phoneNumber: '010-${1000 + random.nextInt(9000)}-${1000 + random.nextInt(9000)}',
        type: userType,
        status: userStatus,
        joinDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        lastLoginDate: userStatus == UserStatus.active 
            ? DateTime.now().subtract(Duration(days: random.nextInt(7)))
            : null,
        isVerified: random.nextBool(),
        campaignCount: random.nextInt(50),
        totalRevenue: random.nextDouble() * 10000000,
        averageRating: 3.0 + random.nextDouble() * 2.0,
        reportCount: random.nextInt(5),
      ));
    }
    
    return users;
  }

  /// 사용자 상태 변경
  Future<bool> updateUserStatus(String userId, UserStatus status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // 목업: 80% 확률로 성공
    return Random().nextInt(10) < 8;
  }

  /// 사용자 상세 정보 조회
  Future<AdminUserInfo?> getUserDetails(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final random = Random();
    return AdminUserInfo(
      id: userId,
      name: '사용자 상세정보',
      email: 'detailed@example.com',
      phoneNumber: '010-1234-5678',
      type: UserType.influencer,
      status: UserStatus.active,
      joinDate: DateTime.now().subtract(const Duration(days: 120)),
      lastLoginDate: DateTime.now().subtract(const Duration(hours: 2)),
      isVerified: true,
      campaignCount: 25,
      totalRevenue: 5500000,
      averageRating: 4.2,
      reportCount: 1,
    );
  }

  /// 캠페인 목록 조회
  Future<List<AdminCampaignInfo>> getCampaigns({
    int page = 1,
    int limit = 20,
    CampaignStatus? status,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final random = Random();
    final campaigns = <AdminCampaignInfo>[];
    final categories = ['뷰티', '패션', '라이프스타일', '푸드', '여행', '테크'];
    
    for (int i = 0; i < limit; i++) {
      final campaignStatus = status ?? CampaignStatus.values[random.nextInt(CampaignStatus.values.length)];
      final startDate = DateTime.now().add(Duration(days: random.nextInt(30) - 15));
      
      campaigns.add(AdminCampaignInfo(
        id: 'campaign_${page}_$i',
        title: '캠페인 ${(page - 1) * limit + i + 1}',
        sellerId: 'seller_$i',
        sellerName: '판매사${i + 1}',
        category: categories[random.nextInt(categories.length)],
        budget: (random.nextDouble() * 5000000) + 500000,
        startDate: startDate,
        endDate: startDate.add(Duration(days: 7 + random.nextInt(23))),
        status: campaignStatus,
        applicantCount: random.nextInt(50) + 5,
        selectedCount: random.nextInt(10) + 1,
        createdDate: DateTime.now().subtract(Duration(days: random.nextInt(60))),
        isReported: random.nextInt(10) == 0,
        averageRating: 3.5 + random.nextDouble() * 1.5,
      ));
    }
    
    return campaigns;
  }

  /// 캠페인 상태 변경
  Future<bool> updateCampaignStatus(String campaignId, CampaignStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 목업: 90% 확률로 성공
    return Random().nextInt(10) < 9;
  }

  /// 신고 목록 조회
  Future<List<ReportInfo>> getReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    ReportType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final random = Random();
    final reports = <ReportInfo>[];
    
    for (int i = 0; i < limit; i++) {
      final reportStatus = status ?? ReportStatus.values[random.nextInt(ReportStatus.values.length)];
      final reportType = type ?? ReportType.values[random.nextInt(ReportType.values.length)];
      final reportDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      
      reports.add(ReportInfo(
        id: 'report_${page}_$i',
        reporterId: 'reporter_$i',
        reporterName: '신고자${i + 1}',
        targetId: 'target_$i',
        targetName: '대상${i + 1}',
        type: reportType,
        category: ReportCategory.values[random.nextInt(ReportCategory.values.length)],
        reason: '신고 사유 ${i + 1}',
        description: '신고 상세 설명입니다. ${reportType.label}에 대한 문제가 발생했습니다.',
        reportDate: reportDate,
        status: reportStatus,
        adminNote: reportStatus != ReportStatus.pending ? '관리자 검토 완료' : null,
        resolvedDate: reportStatus == ReportStatus.resolved ? reportDate.add(const Duration(days: 1)) : null,
        attachments: random.nextBool() ? ['evidence_$i.jpg'] : [],
      ));
    }
    
    return reports;
  }

  /// 신고 처리
  Future<bool> resolveReport(String reportId, ReportStatus status, String? adminNote) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 목업: 95% 확률로 성공
    return Random().nextInt(20) < 19;
  }

  /// 인증 요청 목록 조회
  Future<List<VerificationRequest>> getVerificationRequests({
    int page = 1,
    int limit = 20,
    VerificationStatus? status,
    VerificationType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    final requests = <VerificationRequest>[];
    
    for (int i = 0; i < limit; i++) {
      final verificationStatus = status ?? VerificationStatus.values[random.nextInt(VerificationStatus.values.length)];
      final verificationType = type ?? VerificationType.values[random.nextInt(VerificationType.values.length)];
      final requestDate = DateTime.now().subtract(Duration(days: random.nextInt(14)));
      
      requests.add(VerificationRequest(
        id: 'verification_${page}_$i',
        userId: 'user_$i',
        userName: '인증요청자${i + 1}',
        type: verificationType,
        status: verificationStatus,
        data: {
          'businessNumber': '123-45-67890',
          'businessName': '회사명${i + 1}',
          'representativeName': '대표자${i + 1}',
        },
        documents: ['document_$i.pdf', 'certificate_$i.jpg'],
        requestDate: requestDate,
        reviewDate: verificationStatus != VerificationStatus.pending 
            ? requestDate.add(const Duration(days: 1))
            : null,
        adminNote: verificationStatus == VerificationStatus.approved 
            ? '승인 완료'
            : verificationStatus == VerificationStatus.rejected 
                ? '서류 불충분'
                : null,
        rejectionReason: verificationStatus == VerificationStatus.rejected 
            ? '제출된 서류가 불명확합니다.'
            : null,
      ));
    }
    
    return requests;
  }

  /// 인증 요청 승인/거절
  Future<bool> processVerificationRequest(
    String requestId, 
    VerificationStatus status, 
    String? adminNote,
    String? rejectionReason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // 목업: 항상 성공
    return true;
  }

  /// 시스템 설정 조회
  Future<Map<String, dynamic>> getSystemSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'maintenanceMode': false,
      'allowNewRegistrations': true,
      'minCampaignBudget': 100000,
      'maxCampaignBudget': 10000000,
      'commissionRate': 0.05,
      'autoApproveVerifications': false,
      'maxFileUploadSize': 10, // MB
      'supportedFileTypes': ['jpg', 'png', 'pdf', 'doc', 'docx'],
      'notificationSettings': {
        'emailNotifications': true,
        'smsNotifications': false,
        'pushNotifications': true,
      },
    };
  }

  /// 시스템 설정 업데이트
  Future<bool> updateSystemSettings(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 목업: 항상 성공
    return true;
  }

  /// 플랫폼 공지사항 생성
  Future<bool> createAnnouncement({
    required String title,
    required String content,
    required DateTime startDate,
    required DateTime endDate,
    required bool isImportant,
    List<String>? targetUserTypes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // 목업: 90% 확률로 성공
    return Random().nextInt(10) < 9;
  }

  /// 대량 작업 실행 (예: 대량 이메일 발송)
  Future<bool> executeBulkAction({
    required String action,
    required List<String> targetIds,
    Map<String, dynamic>? parameters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // 목업: 85% 확률로 성공
    return Random().nextInt(20) < 17;
  }

  /// 데이터 내보내기
  Future<String> exportData({
    required String dataType,
    required DateTime startDate,
    required DateTime endDate,
    String? format = 'csv',
  }) async {
    await Future.delayed(const Duration(milliseconds: 3000));
    
    // 목업: 다운로드 URL 반환
    return 'https://api.sellerseller.com/exports/export_${DateTime.now().millisecondsSinceEpoch}.$format';
  }

  /// 로그 조회
  Future<List<Map<String, dynamic>>> getSystemLogs({
    int page = 1,
    int limit = 50,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final random = Random();
    final logs = <Map<String, dynamic>>[];
    final levels = ['DEBUG', 'INFO', 'WARN', 'ERROR'];
    final actions = ['USER_LOGIN', 'CAMPAIGN_CREATED', 'PAYMENT_PROCESSED', 'ERROR_OCCURRED'];
    
    for (int i = 0; i < limit; i++) {
      logs.add({
        'id': 'log_${page}_$i',
        'timestamp': DateTime.now().subtract(Duration(minutes: random.nextInt(1440))).toIso8601String(),
        'level': level ?? levels[random.nextInt(levels.length)],
        'action': actions[random.nextInt(actions.length)],
        'userId': random.nextBool() ? 'user_${random.nextInt(1000)}' : null,
        'message': '시스템 로그 메시지 ${i + 1}',
        'metadata': {
          'ip': '192.168.1.${random.nextInt(255)}',
          'userAgent': 'Mozilla/5.0...',
        },
      });
    }
    
    return logs;
  }

  /// 관리자 권한 확인
  Future<bool> checkAdminPermission(String userId, String permission) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 목업: 관리자 권한 시뮬레이션
    final adminPermissions = [
      'user_management',
      'campaign_management',
      'report_management',
      'verification_management',
      'system_settings',
      'data_export',
      'logs_view',
    ];
    
    return adminPermissions.contains(permission);
  }
}
