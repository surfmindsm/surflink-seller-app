import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  // 기본 통계
  DashboardStats? _stats;
  bool _isLoadingStats = false;
  String? _statsError;

  // 월별 수익
  List<MonthlyEarning>? _monthlyEarnings;
  bool _isLoadingMonthlyEarnings = false;
  String? _monthlyEarningsError;

  // 카테고리별 성과
  List<CategoryPerformance>? _categoryPerformance;
  bool _isLoadingCategoryPerformance = false;
  String? _categoryPerformanceError;

  // 매칭 통계
  MatchingStats? _matchingStats;
  bool _isLoadingMatchingStats = false;
  String? _matchingStatsError;

  // 최근 활동
  List<RecentActivity>? _recentActivities;
  bool _isLoadingRecentActivities = false;
  String? _recentActivitiesError;

  // 인플루언서 랭킹
  Map<String, dynamic>? _influencerRanking;
  bool _isLoadingInfluencerRanking = false;
  String? _influencerRankingError;

  // 트렌드 키워드
  List<Map<String, dynamic>>? _trendingKeywords;
  bool _isLoadingTrendingKeywords = false;
  String? _trendingKeywordsError;

  // 성과 비교
  Map<String, Map<String, dynamic>>? _performanceComparison;
  bool _isLoadingPerformanceComparison = false;
  String? _performanceComparisonError;

  // 추천 캠페인
  List<Map<String, dynamic>>? _recommendedCampaigns;
  bool _isLoadingRecommendedCampaigns = false;
  String? _recommendedCampaignsError;

  // Getters
  DashboardStats? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;

  List<MonthlyEarning>? get monthlyEarnings => _monthlyEarnings;
  bool get isLoadingMonthlyEarnings => _isLoadingMonthlyEarnings;
  String? get monthlyEarningsError => _monthlyEarningsError;

  List<CategoryPerformance>? get categoryPerformance => _categoryPerformance;
  bool get isLoadingCategoryPerformance => _isLoadingCategoryPerformance;
  String? get categoryPerformanceError => _categoryPerformanceError;

  MatchingStats? get matchingStats => _matchingStats;
  bool get isLoadingMatchingStats => _isLoadingMatchingStats;
  String? get matchingStatsError => _matchingStatsError;

  List<RecentActivity>? get recentActivities => _recentActivities;
  bool get isLoadingRecentActivities => _isLoadingRecentActivities;
  String? get recentActivitiesError => _recentActivitiesError;

  Map<String, dynamic>? get influencerRanking => _influencerRanking;
  bool get isLoadingInfluencerRanking => _isLoadingInfluencerRanking;
  String? get influencerRankingError => _influencerRankingError;

  List<Map<String, dynamic>>? get trendingKeywords => _trendingKeywords;
  bool get isLoadingTrendingKeywords => _isLoadingTrendingKeywords;
  String? get trendingKeywordsError => _trendingKeywordsError;

  Map<String, Map<String, dynamic>>? get performanceComparison => _performanceComparison;
  bool get isLoadingPerformanceComparison => _isLoadingPerformanceComparison;
  String? get performanceComparisonError => _performanceComparisonError;

  List<Map<String, dynamic>>? get recommendedCampaigns => _recommendedCampaigns;
  bool get isLoadingRecommendedCampaigns => _isLoadingRecommendedCampaigns;
  String? get recommendedCampaignsError => _recommendedCampaignsError;

  // 전체 로딩 상태
  bool get isLoadingAny =>
      _isLoadingStats ||
      _isLoadingMonthlyEarnings ||
      _isLoadingCategoryPerformance ||
      _isLoadingMatchingStats ||
      _isLoadingRecentActivities ||
      _isLoadingInfluencerRanking ||
      _isLoadingTrendingKeywords ||
      _isLoadingPerformanceComparison ||
      _isLoadingRecommendedCampaigns;

  // Methods
  Future<void> loadDashboardStats(String userId, UserType userType) async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await _dashboardService.getDashboardStats(userId, userType);
    } catch (e) {
      _statsError = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyEarnings(String userId) async {
    _isLoadingMonthlyEarnings = true;
    _monthlyEarningsError = null;
    notifyListeners();

    try {
      _monthlyEarnings = await _dashboardService.getMonthlyEarnings(userId);
    } catch (e) {
      _monthlyEarningsError = e.toString();
    } finally {
      _isLoadingMonthlyEarnings = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryPerformance(String userId) async {
    _isLoadingCategoryPerformance = true;
    _categoryPerformanceError = null;
    notifyListeners();

    try {
      _categoryPerformance = await _dashboardService.getCategoryPerformance(userId);
    } catch (e) {
      _categoryPerformanceError = e.toString();
    } finally {
      _isLoadingCategoryPerformance = false;
      notifyListeners();
    }
  }

  Future<void> loadMatchingStats(String userId) async {
    _isLoadingMatchingStats = true;
    _matchingStatsError = null;
    notifyListeners();

    try {
      _matchingStats = await _dashboardService.getMatchingStats(userId);
    } catch (e) {
      _matchingStatsError = e.toString();
    } finally {
      _isLoadingMatchingStats = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentActivities(String userId) async {
    _isLoadingRecentActivities = true;
    _recentActivitiesError = null;
    notifyListeners();

    try {
      _recentActivities = await _dashboardService.getRecentActivities(userId);
    } catch (e) {
      _recentActivitiesError = e.toString();
    } finally {
      _isLoadingRecentActivities = false;
      notifyListeners();
    }
  }

  Future<void> loadInfluencerRanking(String userId) async {
    _isLoadingInfluencerRanking = true;
    _influencerRankingError = null;
    notifyListeners();

    try {
      _influencerRanking = await _dashboardService.getInfluencerRanking(userId);
    } catch (e) {
      _influencerRankingError = e.toString();
    } finally {
      _isLoadingInfluencerRanking = false;
      notifyListeners();
    }
  }

  Future<void> loadTrendingKeywords() async {
    _isLoadingTrendingKeywords = true;
    _trendingKeywordsError = null;
    notifyListeners();

    try {
      _trendingKeywords = await _dashboardService.getTrendingKeywords();
    } catch (e) {
      _trendingKeywordsError = e.toString();
    } finally {
      _isLoadingTrendingKeywords = false;
      notifyListeners();
    }
  }

  Future<void> loadPerformanceComparison(String userId) async {
    _isLoadingPerformanceComparison = true;
    _performanceComparisonError = null;
    notifyListeners();

    try {
      _performanceComparison = await _dashboardService.getPerformanceComparison(userId);
    } catch (e) {
      _performanceComparisonError = e.toString();
    } finally {
      _isLoadingPerformanceComparison = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendedCampaigns(String userId) async {
    _isLoadingRecommendedCampaigns = true;
    _recommendedCampaignsError = null;
    notifyListeners();

    try {
      _recommendedCampaigns = await _dashboardService.getRecommendedCampaigns(userId);
    } catch (e) {
      _recommendedCampaignsError = e.toString();
    } finally {
      _isLoadingRecommendedCampaigns = false;
      notifyListeners();
    }
  }

  // 모든 데이터 한 번에 로드
  Future<void> loadAllDashboardData(String userId, UserType userType) async {
    await Future.wait([
      loadDashboardStats(userId, userType),
      loadMonthlyEarnings(userId),
      loadCategoryPerformance(userId),
      loadMatchingStats(userId),
      loadRecentActivities(userId),
      if (userType == UserType.influencer) loadInfluencerRanking(userId),
      loadTrendingKeywords(),
      loadPerformanceComparison(userId),
      loadRecommendedCampaigns(userId),
    ]);
  }

  // 데이터 새로고침
  Future<void> refresh(String userId, UserType userType) async {
    clearData();
    await loadAllDashboardData(userId, userType);
  }

  // 데이터 초기화
  void clearData() {
    _stats = null;
    _monthlyEarnings = null;
    _categoryPerformance = null;
    _matchingStats = null;
    _recentActivities = null;
    _influencerRanking = null;
    _trendingKeywords = null;
    _performanceComparison = null;
    _recommendedCampaigns = null;

    _statsError = null;
    _monthlyEarningsError = null;
    _categoryPerformanceError = null;
    _matchingStatsError = null;
    _recentActivitiesError = null;
    _influencerRankingError = null;
    _trendingKeywordsError = null;
    _performanceComparisonError = null;
    _recommendedCampaignsError = null;

    notifyListeners();
  }
}
