import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/campaign_model.dart';

class UserProvider extends ChangeNotifier {
  List<User> _influencers = [];
  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  List<User> get influencers => _influencers;
  List<Campaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider() {
    _loadInitialData();
  }

  // 초기 데이터 로드
  Future<void> _loadInitialData() async {
    await loadInfluencers();
    await loadCampaigns();
  }

  // 인플루언서 목록 로드
  Future<void> loadInfluencers({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      
      // 임시 데이터
      _influencers = [
        User(
          id: '1',
          email: 'influencer1@example.com',
          name: '김인플루',
          nickname: '뷰티인플루',
          type: UserType.influencer,
          status: UserStatus.active,
          followersCount: 50000,
          categories: ['뷰티', '패션'],
          introduction: '뷰티와 패션 분야의 인플루언서입니다.',
          pricePolicy: '건당',
          priceAmount: 500000,
          region: '서울',
          isProfileVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        User(
          id: '2',
          email: 'influencer2@example.com',
          name: '이크리에이터',
          nickname: '푸드크리에이터',
          type: UserType.influencer,
          status: UserStatus.active,
          followersCount: 75000,
          categories: ['음식', '여행'],
          introduction: '맛집 탐방과 여행 콘텐츠를 제작합니다.',
          pricePolicy: '건당',
          priceAmount: 750000,
          region: '부산',
          isProfileVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
        User(
          id: '3',
          email: 'influencer3@example.com',
          name: '박유튜버',
          nickname: '테크리뷰어',
          type: UserType.influencer,
          status: UserStatus.active,
          followersCount: 120000,
          categories: ['테크', '리뷰'],
          introduction: '최신 IT 기기와 가전제품 리뷰를 전문으로 합니다.',
          pricePolicy: '건당',
          priceAmount: 1000000,
          region: '서울',
          isProfileVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 목록 로드
  Future<void> loadCampaigns({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      
      // 임시 데이터
      _campaigns = [
        Campaign(
          id: '1',
          sellerId: 'seller1',
          name: '신제품 화장품 리뷰 캠페인',
          categories: ['뷰티', '스킨케어'],
          budget: 2000000,
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 37)),
          description: '새로 출시된 안티에이징 크림 리뷰 콘텐츠를 제작해주실 인플루언서를 찾습니다.',
          targetConditions: '뷰티 분야 팔로워 3만명 이상, 30대 여성 타겟',
          status: CampaignStatus.recruiting,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Campaign(
          id: '2',
          sellerId: 'seller2',
          name: '맛집 방문 후기 콘텐츠',
          categories: ['음식', '맛집'],
          budget: 1500000,
          startDate: DateTime.now().add(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 23)),
          description: '강남 신규 오픈 레스토랑 방문 후기와 음식 리뷰 콘텐츠 제작',
          targetConditions: '푸드 인플루언서, 서울 거주자 우대',
          status: CampaignStatus.recruiting,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Campaign(
          id: '3',
          sellerId: 'seller3',
          name: '스마트워치 체험단 모집',
          categories: ['테크', '리뷰', '피트니스'],
          budget: 3000000,
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 40)),
          description: '최신 스마트워치 2주간 체험 후 상세 리뷰 콘텐츠 제작',
          targetConditions: '테크 리뷰 전문, 피트니스 관련 콘텐츠 경험자',
          status: CampaignStatus.recruiting,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 인플루언서 필터링
  List<User> getFilteredInfluencers({
    List<String>? categories,
    String? region,
    int? minFollowers,
    int? maxFollowers,
    bool? isVerified,
  }) {
    return _influencers.where((user) {
      if (categories != null && categories.isNotEmpty) {
        if (user.categories == null || 
            !categories.any((cat) => user.categories!.contains(cat))) {
          return false;
        }
      }
      
      if (region != null && user.region != region) {
        return false;
      }
      
      if (minFollowers != null && 
          (user.followersCount == null || user.followersCount! < minFollowers)) {
        return false;
      }
      
      if (maxFollowers != null && 
          (user.followersCount == null || user.followersCount! > maxFollowers)) {
        return false;
      }
      
      if (isVerified != null && user.isProfileVerified != isVerified) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // 캠페인 검색
  List<Campaign> searchCampaigns(String query) {
    if (query.isEmpty) return _campaigns;
    
    return _campaigns.where((campaign) {
      return campaign.name.toLowerCase().contains(query.toLowerCase()) ||
             campaign.description.toLowerCase().contains(query.toLowerCase()) ||
             campaign.categories.any((cat) => 
                cat.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
