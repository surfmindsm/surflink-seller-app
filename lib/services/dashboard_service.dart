import '../models/dashboard_model.dart';
import '../models/user_model.dart';

class DashboardService {
  // 대시보드 통계 가져오기
  Future<DashboardStats> getDashboardStats(String userId, UserType userType) async {
    // 실제 API 호출을 시뮬레이션하기 위한 지연
    await Future.delayed(const Duration(milliseconds: 1000));

    if (userType == UserType.influencer) {
      return DashboardStats(
        totalCampaigns: 24,
        activeCampaigns: 3,
        completedCampaigns: 18,
        totalApplications: 45,
        acceptedApplications: 32,
        averageRating: 4.7,
        totalEarnings: 15420000,
        thisMonthEarnings: 2340000,
      );
    } else {
      // 판매사용 통계
      return DashboardStats(
        totalCampaigns: 12,
        activeCampaigns: 2,
        completedCampaigns: 8,
        totalApplications: 89,
        acceptedApplications: 56,
        averageRating: 4.5,
        totalEarnings: 45600000,
        thisMonthEarnings: 7800000,
      );
    }
  }

  // 월별 수익 데이터 가져오기
  Future<List<MonthlyEarning>> getMonthlyEarnings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = now.month - index;
      final year = month > 0 ? now.year : now.year - 1;
      final adjustedMonth = month > 0 ? month : 12 + month;

      return MonthlyEarning(
        month: adjustedMonth,
        year: year,
        amount: (1000000 + (index * 200000)) + (adjustedMonth * 50000),
        campaignCount: 2 + index,
      );
    }).reversed.toList();
  }

  // 카테고리별 성과 데이터 가져오기
  Future<List<CategoryPerformance>> getCategoryPerformance(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      CategoryPerformance(
        category: '뷰티',
        campaignCount: 8,
        totalEarnings: 4200000,
        averageRating: 4.8,
        viewCount: 125000,
        clickCount: 6250,
      ),
      CategoryPerformance(
        category: '패션',
        campaignCount: 6,
        totalEarnings: 3100000,
        averageRating: 4.6,
        viewCount: 98000,
        clickCount: 4900,
      ),
      CategoryPerformance(
        category: '음식',
        campaignCount: 4,
        totalEarnings: 2400000,
        averageRating: 4.9,
        viewCount: 87000,
        clickCount: 5220,
      ),
      CategoryPerformance(
        category: '여행',
        campaignCount: 3,
        totalEarnings: 1800000,
        averageRating: 4.5,
        viewCount: 65000,
        clickCount: 3250,
      ),
      CategoryPerformance(
        category: '테크',
        campaignCount: 3,
        totalEarnings: 1900000,
        averageRating: 4.7,
        viewCount: 72000,
        clickCount: 4320,
      ),
    ];
  }

  // 매칭 통계 가져오기
  Future<MatchingStats> getMatchingStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return MatchingStats(
      totalMatches: 87,
      successfulMatches: 56,
      pendingMatches: 12,
      rejectedMatches: 19,
      successRate: 64.4,
    );
  }

  // 최근 활동 가져오기
  Future<List<RecentActivity>> getRecentActivities(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();
    return [
      RecentActivity(
        id: '1',
        type: 'campaign',
        title: '새 캠페인 시작',
        description: 'ABC 브랜드 신제품 런칭 캠페인이 시작되었습니다.',
        createdAt: now.subtract(const Duration(hours: 2)),
        imageUrl: 'https://via.placeholder.com/150',
      ),
      RecentActivity(
        id: '2',
        type: 'match',
        title: '매칭 성공',
        description: '뷰티 인플루언서 김○○님과 매칭되었습니다.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      RecentActivity(
        id: '3',
        type: 'application',
        title: '지원서 승인',
        description: 'XYZ 패션 캠페인 지원서가 승인되었습니다.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      RecentActivity(
        id: '4',
        type: 'review',
        title: '리뷰 등록',
        description: '완료된 캠페인에 대한 리뷰를 받았습니다. (★★★★★)',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      RecentActivity(
        id: '5',
        type: 'campaign',
        title: '캠페인 완료',
        description: '헬스케어 브랜드 캠페인이 성공적으로 완료되었습니다.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // 인플루언서 랭킹 정보
  Future<Map<String, dynamic>> getInfluencerRanking(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'current_rank': 156,
      'total_influencers': 2847,
      'ranking_change': '+12', // +상승, -하락
      'category_rank': {
        '뷰티': 23,
        '패션': 45,
        '음식': 67,
      },
      'points': 8945,
      'next_level_points': 10000,
    };
  }

  // 트렌드 키워드 가져오기
  Future<List<Map<String, dynamic>>> getTrendingKeywords() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {'keyword': '비건뷰티', 'change': '+23%', 'trend': 'up'},
      {'keyword': '친환경패션', 'change': '+18%', 'trend': 'up'},
      {'keyword': '홈카페', 'change': '+15%', 'trend': 'up'},
      {'keyword': '미니멀라이프', 'change': '+12%', 'trend': 'up'},
      {'keyword': '반려동물', 'change': '+8%', 'trend': 'up'},
      {'keyword': '해외여행', 'change': '-5%', 'trend': 'down'},
      {'keyword': '럭셔리', 'change': '-12%', 'trend': 'down'},
    ];
  }

  // 성과 비교 데이터 (전월 대비)
  Future<Map<String, Map<String, dynamic>>> getPerformanceComparison(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'earnings': {
        'current': 2340000,
        'previous': 1890000,
        'change_percent': 23.8,
        'trend': 'up',
      },
      'campaigns': {
        'current': 3,
        'previous': 2,
        'change_percent': 50.0,
        'trend': 'up',
      },
      'applications': {
        'current': 8,
        'previous': 12,
        'change_percent': -33.3,
        'trend': 'down',
      },
      'rating': {
        'current': 4.7,
        'previous': 4.5,
        'change_percent': 4.4,
        'trend': 'up',
      },
    };
  }

  // 추천 캠페인 가져오기
  Future<List<Map<String, dynamic>>> getRecommendedCampaigns(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 'rec1',
        'title': '신상 스킨케어 체험단',
        'brand': 'Beauty Co.',
        'category': '뷰티',
        'budget': 500000,
        'match_score': 95,
        'deadline': DateTime.now().add(const Duration(days: 7)),
      },
      {
        'id': 'rec2',
        'title': '여름 패션 룩북',
        'brand': 'Fashion Plus',
        'category': '패션',
        'budget': 800000,
        'match_score': 89,
        'deadline': DateTime.now().add(const Duration(days: 14)),
      },
      {
        'id': 'rec3',
        'title': '홈카페 원두 리뷰',
        'brand': 'Coffee Bean',
        'category': '음식',
        'budget': 300000,
        'match_score': 82,
        'deadline': DateTime.now().add(const Duration(days: 10)),
      },
    ];
  }
}
