/// 관리자 백오피스 관련 모델

/// 관리자 대시보드 통계
class AdminDashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalCampaigns;
  final int activeCampaigns;
  final int pendingVerifications;
  final int pendingReports;
  final double totalRevenue;
  final double monthlyRevenue;
  final List<DailyStats> dailyStats;
  final List<CategoryStats> categoryStats;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.pendingVerifications,
    required this.pendingReports,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyStats,
    required this.categoryStats,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalCampaigns': totalCampaigns,
      'activeCampaigns': activeCampaigns,
      'pendingVerifications': pendingVerifications,
      'pendingReports': pendingReports,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'dailyStats': dailyStats.map((s) => s.toJson()).toList(),
      'categoryStats': categoryStats.map((s) => s.toJson()).toList(),
    };
  }

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalCampaigns: json['totalCampaigns'] ?? 0,
      activeCampaigns: json['activeCampaigns'] ?? 0,
      pendingVerifications: json['pendingVerifications'] ?? 0,
      pendingReports: json['pendingReports'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      dailyStats: (json['dailyStats'] as List? ?? [])
          .map((s) => DailyStats.fromJson(s))
          .toList(),
      categoryStats: (json['categoryStats'] as List? ?? [])
          .map((s) => CategoryStats.fromJson(s))
          .toList(),
    );
  }
}

/// 일일 통계
class DailyStats {
  final DateTime date;
  final int newUsers;
  final int newCampaigns;
  final double revenue;

  const DailyStats({
    required this.date,
    required this.newUsers,
    required this.newCampaigns,
    required this.revenue,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'newUsers': newUsers,
      'newCampaigns': newCampaigns,
      'revenue': revenue,
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      newUsers: json['newUsers'] ?? 0,
      newCampaigns: json['newCampaigns'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

/// 카테고리별 통계
class CategoryStats {
  final String category;
  final int campaignCount;
  final double revenue;
  final double averageRating;

  const CategoryStats({
    required this.category,
    required this.campaignCount,
    required this.revenue,
    required this.averageRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'campaignCount': campaignCount,
      'revenue': revenue,
      'averageRating': averageRating,
    };
  }

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      category: json['category'] ?? '',
      campaignCount: json['campaignCount'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

/// 사용자 관리 정보
class AdminUserInfo {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final UserType type;
  final UserStatus status;
  final DateTime joinDate;
  final DateTime? lastLoginDate;
  final bool isVerified;
  final int campaignCount;
  final double totalRevenue;
  final double averageRating;
  final int reportCount;

  const AdminUserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.type,
    required this.status,
    required this.joinDate,
    this.lastLoginDate,
    required this.isVerified,
    required this.campaignCount,
    required this.totalRevenue,
    required this.averageRating,
    required this.reportCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'type': type.name,
      'status': status.name,
      'joinDate': joinDate.toIso8601String(),
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'isVerified': isVerified,
      'campaignCount': campaignCount,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
      'reportCount': reportCount,
    };
  }

  factory AdminUserInfo.fromJson(Map<String, dynamic> json) {
    return AdminUserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      type: UserType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => UserType.influencer,
      ),
      status: UserStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      joinDate: DateTime.parse(json['joinDate']),
      lastLoginDate: json['lastLoginDate'] != null 
          ? DateTime.parse(json['lastLoginDate']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      campaignCount: json['campaignCount'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reportCount: json['reportCount'] ?? 0,
    );
  }
}

/// 사용자 상태
enum UserStatus {
  active('활성'),
  suspended('정지'),
  pending('대기'),
  banned('차단');

  const UserStatus(this.label);
  
  final String label;
}

/// 사용자 타입 (기존에 있을 수 있지만 여기서 정의)
enum UserType {
  influencer('인플루언서'),
  seller('판매사'),
  admin('관리자');

  const UserType(this.label);
  
  final String label;
}

/// 신고 정보
class ReportInfo {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetId;
  final String targetName;
  final ReportType type;
  final ReportCategory category;
  final String reason;
  final String description;
  final DateTime reportDate;
  final ReportStatus status;
  final String? adminNote;
  final DateTime? resolvedDate;
  final List<String> attachments;

  const ReportInfo({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetId,
    required this.targetName,
    required this.type,
    required this.category,
    required this.reason,
    required this.description,
    required this.reportDate,
    required this.status,
    this.adminNote,
    this.resolvedDate,
    required this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'targetId': targetId,
      'targetName': targetName,
      'type': type.name,
      'category': category.name,
      'reason': reason,
      'description': description,
      'reportDate': reportDate.toIso8601String(),
      'status': status.name,
      'adminNote': adminNote,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory ReportInfo.fromJson(Map<String, dynamic> json) {
    return ReportInfo(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      targetId: json['targetId'] ?? '',
      targetName: json['targetName'] ?? '',
      type: ReportType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReportType.user,
      ),
      category: ReportCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ReportCategory.inappropriate,
      ),
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      reportDate: DateTime.parse(json['reportDate']),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      adminNote: json['adminNote'],
      resolvedDate: json['resolvedDate'] != null 
          ? DateTime.parse(json['resolvedDate']) 
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }
}

/// 신고 타입
enum ReportType {
  user('사용자'),
  campaign('캠페인'),
  review('리뷰'),
  message('메시지');

  const ReportType(this.label);
  
  final String label;
}

/// 신고 카테고리
enum ReportCategory {
  inappropriate('부적절한 내용'),
  spam('스팸'),
  fraud('사기'),
  harassment('괴롭힘'),
  copyright('저작권 침해'),
  other('기타');

  const ReportCategory(this.label);
  
  final String label;
}

/// 신고 상태
enum ReportStatus {
  pending('대기중'),
  reviewing('검토중'),
  resolved('해결됨'),
  dismissed('기각됨');

  const ReportStatus(this.label);
  
  final String label;
}

/// 캠페인 관리 정보
class AdminCampaignInfo {
  final String id;
  final String title;
  final String sellerId;
  final String sellerName;
  final String category;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final CampaignStatus status;
  final int applicantCount;
  final int selectedCount;
  final DateTime createdDate;
  final bool isReported;
  final double averageRating;

  const AdminCampaignInfo({
    required this.id,
    required this.title,
    required this.sellerId,
    required this.sellerName,
    required this.category,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.applicantCount,
    required this.selectedCount,
    required this.createdDate,
    required this.isReported,
    required this.averageRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'category': category,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'applicantCount': applicantCount,
      'selectedCount': selectedCount,
      'createdDate': createdDate.toIso8601String(),
      'isReported': isReported,
      'averageRating': averageRating,
    };
  }

  factory AdminCampaignInfo.fromJson(Map<String, dynamic> json) {
    return AdminCampaignInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      category: json['category'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: CampaignStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CampaignStatus.active,
      ),
      applicantCount: json['applicantCount'] ?? 0,
      selectedCount: json['selectedCount'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
      isReported: json['isReported'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

/// 캠페인 상태
enum CampaignStatus {
  draft('초안'),
  active('활성'),
  paused('일시정지'),
  completed('완료'),
  cancelled('취소');

  const CampaignStatus(this.label);
  
  final String label;
}

/// 인증 요청 정보
class VerificationRequest {
  final String id;
  final String userId;
  final String userName;
  final VerificationType type;
  final VerificationStatus status;
  final Map<String, dynamic> data;
  final List<String> documents;
  final DateTime requestDate;
  final DateTime? reviewDate;
  final String? adminNote;
  final String? rejectionReason;

  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    required this.data,
    required this.documents,
    required this.requestDate,
    this.reviewDate,
    this.adminNote,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'status': status.name,
      'data': data,
      'documents': documents,
      'requestDate': requestDate.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'adminNote': adminNote,
      'rejectionReason': rejectionReason,
    };
  }

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      type: VerificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => VerificationType.identity,
      ),
      status: VerificationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      documents: List<String>.from(json['documents'] ?? []),
      requestDate: DateTime.parse(json['requestDate']),
      reviewDate: json['reviewDate'] != null 
          ? DateTime.parse(json['reviewDate']) 
          : null,
      adminNote: json['adminNote'],
      rejectionReason: json['rejectionReason'],
    );
  }
}

/// 인증 타입 (기존에 있을 수 있지만 여기서 정의)
enum VerificationType {
  identity('신원인증'),
  business('사업자인증'),
  sns('SNS인증'),
  portfolio('포트폴리오인증'),
  phone('전화번호인증'),
  email('이메일인증');

  const VerificationType(this.label);
  
  final String label;
}

/// 인증 상태 (기존에 있을 수 있지만 여기서 정의)
enum VerificationStatus {
  pending('대기중'),
  approved('승인됨'),
  rejected('거절됨'),
  expired('만료됨');

  const VerificationStatus(this.label);
  
  final String label;
}
