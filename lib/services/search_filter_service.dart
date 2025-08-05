import 'dart:async';
import 'dart:math';
import '../models/search_filter_model.dart';
import '../models/campaign_model.dart';
import '../models/user_model.dart';

class SearchFilterService {
  static final SearchFilterService _instance = SearchFilterService._internal();
  factory SearchFilterService() => _instance;
  SearchFilterService._internal();

  final Random _random = Random();

  // 캠페인 검색
  Future<SearchResult<Campaign>> searchCampaigns({
    required SearchFilter filter,
    int page = 1,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();
    await Future.delayed(const Duration(milliseconds: 500));

    // 목업 캠페인 생성
    final allCampaigns = _generateMockCampaigns(200);
    
    // 필터 적용
    var filteredCampaigns = _applyCampaignFilters(allCampaigns, filter);
    
    // 정렬 적용
    _applyCampaignSorting(filteredCampaigns, filter);
    
    // 페이지네이션
    final totalCount = filteredCampaigns.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, totalCount);
    final pagedCampaigns = filteredCampaigns.sublist(
      startIndex.clamp(0, totalCount),
      endIndex,
    );

    stopwatch.stop();
    
    return SearchResult<Campaign>(
      items: pagedCampaigns,
      totalCount: totalCount,
      currentPage: page,
      totalPages: totalPages,
      hasMore: page < totalPages,
      appliedFilter: filter,
      searchDuration: stopwatch.elapsed,
    );
  }

  // 인플루언서 검색
  Future<SearchResult<User>> searchInfluencers({
    required SearchFilter filter,
    int page = 1,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();
    await Future.delayed(const Duration(milliseconds: 400));

    // 목업 인플루언서 생성
    final allInfluencers = _generateMockInfluencers(150);
    
    // 필터 적용
    var filteredInfluencers = _applyInfluencerFilters(allInfluencers, filter);
    
    // 정렬 적용
    _applyInfluencerSorting(filteredInfluencers, filter);
    
    // 페이지네이션
    final totalCount = filteredInfluencers.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, totalCount);
    final pagedInfluencers = filteredInfluencers.sublist(
      startIndex.clamp(0, totalCount),
      endIndex,
    );

    stopwatch.stop();
    
    return SearchResult<User>(
      items: pagedInfluencers,
      totalCount: totalCount,
      currentPage: page,
      totalPages: totalPages,
      hasMore: page < totalPages,
      appliedFilter: filter,
      searchDuration: stopwatch.elapsed,
    );
  }

  // 저장된 검색 조건 관리
  Future<List<SavedSearch>> getSavedSearches(String userId, SearchTargetType targetType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final savedSearches = <SavedSearch>[];
    final now = DateTime.now();
    
    // 목업 저장된 검색 생성
    for (int i = 0; i < 5; i++) {
      final filter = _generateMockFilter(targetType);
      savedSearches.add(SavedSearch(
        id: 'saved_${i + 1}',
        name: _getSavedSearchName(targetType, i),
        description: _getSavedSearchDescription(targetType, i),
        searchFilter: filter.copyWith(isSaved: true),
        useCount: _random.nextInt(20) + 1,
        createdAt: now.subtract(Duration(days: i * 7)),
        lastUsedAt: now.subtract(Duration(days: _random.nextInt(7))),
        updatedAt: now.subtract(Duration(days: i * 5)),
      ));
    }
    
    return savedSearches;
  }

  Future<bool> saveSearch(String userId, SavedSearch savedSearch) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> deleteSavedSearch(String userId, String searchId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> updateSavedSearch(String userId, SavedSearch savedSearch) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  // 검색 제안
  Future<List<String>> getSuggestions(String query, SearchTargetType targetType) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (query.isEmpty) return [];
    
    final suggestions = <String>[];
    
    switch (targetType) {
      case SearchTargetType.campaign:
        suggestions.addAll([
          '뷰티 제품 리뷰',
          '패션 브랜드 협업',
          '푸드 체험단',
          '여행 상품 홍보',
          '테크 제품 리뷰',
          '라이프스타일',
          '건강 관리',
          '반려동물',
        ]);
        break;
      case SearchTargetType.influencer:
        suggestions.addAll([
          '뷰티 인플루언서',
          '패션 인플루언서',
          '푸드 블로거',
          '여행 블로거',
          '테크 리뷰어',
          '라이프스타일 크리에이터',
          '반려동물 계정',
        ]);
        break;
      default:
        suggestions.addAll([
          query + ' 관련',
          query + ' 추천',
          query + ' 인기',
        ]);
    }
    
    return suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  // 인기 검색어
  Future<List<String>> getPopularKeywords(SearchTargetType targetType) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    switch (targetType) {
      case SearchTargetType.campaign:
        return ['뷰티', '패션', '푸드', '여행', '테크', '라이프스타일', '건강', '반려동물'];
      case SearchTargetType.influencer:
        return ['뷰티크리에이터', '패션인플루언서', '푸드블로거', '여행블로거', '테크리뷰어'];
      default:
        return ['인기', '추천', '최신', '높은평점'];
    }
  }

  // 필터 옵션 데이터
  Map<String, List<String>> getFilterOptions(SearchTargetType targetType) {
    switch (targetType) {
      case SearchTargetType.campaign:
        return {
          'categories': ['뷰티', '패션', '푸드', '여행', '테크', '라이프스타일', '건강', '반려동물', '육아', '인테리어'],
          'regions': ['전국', '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'],
          'statuses': ['모집중', '진행중', '완료', '취소'],
          'platforms': ['인스타그램', '유튜브', '틱톡', '네이버블로그', '카카오스토리'],
        };
      case SearchTargetType.influencer:
        return {
          'categories': ['뷰티', '패션', '푸드', '여행', '테크', '라이프스타일', '건강', '반려동물', '육아', '인테리어'],
          'regions': ['전국', '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'],
          'platforms': ['인스타그램', '유튜브', '틱톡', '네이버블로그', '카카오스토리'],
        };
      default:
        return {};
    }
  }

  // 프리셋 필터
  List<SearchFilter> getPresetFilters(SearchTargetType targetType) {
    final now = DateTime.now();
    
    switch (targetType) {
      case SearchTargetType.campaign:
        return [
          SearchFilter(
            id: 'preset_high_budget',
            name: '고예산 캠페인',
            targetType: targetType,
            priceRange: PriceRange(min: 1000000),
            sortOption: SortOption.priceDesc,
            createdAt: now,
            updatedAt: now,
          ),
          SearchFilter(
            id: 'preset_urgent',
            name: '급구 캠페인',
            targetType: targetType,
            endDate: now.add(const Duration(days: 7)),
            sortOption: SortOption.deadline,
            createdAt: now,
            updatedAt: now,
          ),
          SearchFilter(
            id: 'preset_popular',
            name: '인기 캠페인',
            targetType: targetType,
            sortOption: SortOption.popular,
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case SearchTargetType.influencer:
        return [
          SearchFilter(
            id: 'preset_verified',
            name: '인증된 인플루언서',
            targetType: targetType,
            isVerified: true,
            sortOption: SortOption.rating,
            createdAt: now,
            updatedAt: now,
          ),
          SearchFilter(
            id: 'preset_popular',
            name: '인기 인플루언서',
            targetType: targetType,
            followerRange: FollowerRange(min: 10000),
            sortOption: SortOption.followers,
            createdAt: now,
            updatedAt: now,
          ),
          SearchFilter(
            id: 'preset_high_engagement',
            name: '높은 참여율',
            targetType: targetType,
            sortOption: SortOption.engagement,
            createdAt: now,
            updatedAt: now,
          ),
        ];
      default:
        return [];
    }
  }

  // 목업 데이터 생성 메서드들
  List<Campaign> _generateMockCampaigns(int count) {
    final campaigns = <Campaign>[];
    final categories = ['뷰티', '패션', '푸드', '여행', '테크', '라이프스타일'];
    final statuses = ['모집중', '진행중', '완료'];
    
    for (int i = 0; i < count; i++) {
      final category = categories[_random.nextInt(categories.length)];
      final status = statuses[_random.nextInt(statuses.length)];
      
      campaigns.add(Campaign(
        id: 'campaign_$i',
        sellerId: 'seller_${_random.nextInt(50)}',
        name: '$category ${_getCampaignTitleSuffix()} ${i + 1}',
        categories: [category],
        budget: (_random.nextInt(20) + 1) * 100000,
        startDate: DateTime.now().add(Duration(days: _random.nextInt(30))),
        endDate: DateTime.now().add(Duration(days: 30 + _random.nextInt(60))),
        description: '$category 관련 협업 캠페인입니다.',
        targetConditions: '$category 관련 콘텐츠 제작 경험이 있는 인플루언서',
        status: _getStatusFromString(status),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt: DateTime.now().subtract(Duration(hours: _random.nextInt(24))),
        applicantIds: List.generate(_random.nextInt(10), (i) => 'applicant_$i'),
        maxApplicants: _random.nextInt(20) + 5,
      ));
    }
    
    return campaigns;
  }

  List<User> _generateMockInfluencers(int count) {
    final users = <User>[];
    final categories = ['뷰티', '패션', '푸드', '여행', '테크', '라이프스타일'];
    final regions = ['서울', '경기', '인천', '부산', '대구'];
    
    for (int i = 0; i < count; i++) {
      final category = categories[_random.nextInt(categories.length)];
      final region = regions[_random.nextInt(regions.length)];
      
      users.add(User(
        id: 'influencer_$i',
        email: 'influencer$i@example.com',
        name: '$category 인플루언서 ${i + 1}',
        type: UserType.influencer,
        status: UserStatus.active,
        phone: '010-0000-${1000 + i}',
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        updatedAt: DateTime.now().subtract(Duration(hours: _random.nextInt(72))),
        nickname: '${category.toLowerCase()}_creator_$i',
        region: region,
        followersCount: _random.nextInt(100000) + 1000,
        categories: [category],
      ));
    }
    
    return users;
  }

  String _getCampaignTitleSuffix() {
    final suffixes = ['신제품 리뷰', '브랜드 협업', '체험단', '홍보', '런칭 이벤트'];
    return suffixes[_random.nextInt(suffixes.length)];
  }

  CampaignStatus _getStatusFromString(String status) {
    switch (status) {
      case '모집중':
        return CampaignStatus.recruiting;
      case '진행중':
        return CampaignStatus.active;
      case '완료':
        return CampaignStatus.completed;
      default:
        return CampaignStatus.recruiting;
    }
  }

  SearchFilter _generateMockFilter(SearchTargetType targetType) {
    final now = DateTime.now();
    final categories = getFilterOptions(targetType)['categories'] ?? [];
    final regions = getFilterOptions(targetType)['regions'] ?? [];
    
    return SearchFilter(
      id: 'mock_filter_${now.millisecondsSinceEpoch}',
      name: '테스트 필터',
      targetType: targetType,
      categories: [categories[_random.nextInt(categories.length)]],
      regions: [regions[_random.nextInt(regions.length)]],
      createdAt: now,
      updatedAt: now,
    );
  }

  String _getSavedSearchName(SearchTargetType targetType, int index) {
    switch (targetType) {
      case SearchTargetType.campaign:
        return ['고예산 뷰티 캠페인', '서울 패션 협업', '급구 푸드 체험단', '여행 브랜드 런칭', '테크 신제품 리뷰'][index];
      case SearchTargetType.influencer:
        return ['인증된 뷰티 크리에이터', '서울 패션 인플루언서', '고참여율 푸드 블로거', '여행 전문 블로거', '테크 리뷰어'][index];
      default:
        return '저장된 검색 ${index + 1}';
    }
  }

  String _getSavedSearchDescription(SearchTargetType targetType, int index) {
    switch (targetType) {
      case SearchTargetType.campaign:
        return '자주 찾는 캠페인 조건입니다';
      case SearchTargetType.influencer:
        return '선호하는 인플루언서 조건입니다';
      default:
        return '자주 사용하는 검색 조건입니다';
    }
  }

  // 캠페인 필터링
  List<Campaign> _applyCampaignFilters(List<Campaign> campaigns, SearchFilter filter) {
    return campaigns.where((campaign) {
      // 키워드 검색
      if (filter.keyword?.isNotEmpty == true) {
        final keyword = filter.keyword!.toLowerCase();
        if (!campaign.name.toLowerCase().contains(keyword) &&
            !campaign.description.toLowerCase().contains(keyword)) {
          return false;
        }
      }
      
      // 카테고리 필터
      if (filter.categories.isNotEmpty) {
        final hasMatchingCategory = campaign.categories.any((category) => 
          filter.categories.contains(category));
        if (!hasMatchingCategory) return false;
      }
      
      // 예산 필터
      if (filter.priceRange != null && !filter.priceRange!.isEmpty) {
        if (!filter.priceRange!.contains(campaign.budget.toDouble())) return false;
      }
      
      // 상태 필터
      if (filter.statuses.isNotEmpty) {
        if (!filter.statuses.contains(campaign.status)) return false;
      }
      
      // 날짜 필터
      if (filter.startDate != null) {
        if (campaign.startDate.isBefore(filter.startDate!)) return false;
      }
      if (filter.endDate != null) {
        if (campaign.endDate.isAfter(filter.endDate!)) return false;
      }
      
      return true;
    }).toList();
  }

  // 인플루언서 필터링
  List<User> _applyInfluencerFilters(List<User> influencers, SearchFilter filter) {
    return influencers.where((user) {
      // 키워드 검색
      if (filter.keyword?.isNotEmpty == true) {
        final keyword = filter.keyword!.toLowerCase();
        if (!user.name.toLowerCase().contains(keyword) &&
            !(user.nickname?.toLowerCase().contains(keyword) ?? false)) {
          return false;
        }
      }
      
      // 카테고리 필터
      if (filter.categories.isNotEmpty) {
        if (!(user.categories?.any((cat) => filter.categories.contains(cat)) ?? false)) {
          return false;
        }
      }
      
      // 지역 필터
      if (filter.regions.isNotEmpty) {
        if (!filter.regions.contains(user.region)) return false;
      }
      
      // 팁로워 수 필터
      if (filter.followerRange != null && !filter.followerRange!.isEmpty) {
        if (user.followersCount != null && !filter.followerRange!.contains(user.followersCount!)) return false;
      }
      
      return true;
    }).toList();
  }

  // 캠페인 정렬
  void _applyCampaignSorting(List<Campaign> campaigns, SearchFilter filter) {
    campaigns.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortOption) {
        case SortOption.latest:
          comparison = b.createdAt.compareTo(a.createdAt);
          break;
        case SortOption.oldest:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;

        case SortOption.priceAsc:
          comparison = a.budget.compareTo(b.budget);
          break;
        case SortOption.priceDesc:
          comparison = b.budget.compareTo(a.budget);
          break;
        case SortOption.deadline:
          comparison = a.endDate.compareTo(b.endDate);
          break;
        case SortOption.alphabet:
          comparison = a.name.compareTo(b.name);
          break;
        default:
          comparison = b.createdAt.compareTo(a.createdAt);
      }
      
      return filter.sortDescending ? comparison : -comparison;
    });
  }

  // 인플루언서 정렬
  void _applyInfluencerSorting(List<User> influencers, SearchFilter filter) {
    influencers.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortOption) {
        case SortOption.latest:
          comparison = b.createdAt.compareTo(a.createdAt);
          break;
        case SortOption.oldest:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortOption.alphabet:
          comparison = a.name.compareTo(b.name);
          break;
        default:
          comparison = b.createdAt.compareTo(a.createdAt);
      }
      
      return filter.sortDescending ? comparison : -comparison;
    });
  }
}
