import 'package:flutter/material.dart';
import '../models/search_filter_model.dart';
import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../services/search_filter_service.dart';

class SearchFilterProvider extends ChangeNotifier {
  final SearchFilterService _searchService = SearchFilterService();

  // 현재 검색 필터
  SearchFilter? _currentFilter;
  SearchFilter? get currentFilter => _currentFilter;

  // 검색 결과
  SearchResult<Campaign>? _campaignResults;
  SearchResult<Campaign>? get campaignResults => _campaignResults;

  SearchResult<User>? _influencerResults;
  SearchResult<User>? get influencerResults => _influencerResults;

  // 저장된 검색 조건
  List<SavedSearch>? _savedSearches;
  List<SavedSearch>? get savedSearches => _savedSearches;

  // 검색 제안
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;

  // 인기 검색어
  List<String> _popularKeywords = [];
  List<String> get popularKeywords => _popularKeywords;

  // 로딩 상태
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoadingSavedSearches = false;
  bool get isLoadingSavedSearches => _isLoadingSavedSearches;

  bool _isLoadingSuggestions = false;
  bool get isLoadingSuggestions => _isLoadingSuggestions;

  // 에러 상태
  String? _searchError;
  String? get searchError => _searchError;

  String? _savedSearchError;
  String? get savedSearchError => _savedSearchError;

  // 페이지네이션
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMoreResults = false;
  bool get hasMoreResults => _hasMoreResults;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  SearchResult? _searchResults;
  SearchResult? get searchResults => _searchResults;

  // 필터 초기화
  void initializeFilter(SearchTargetType targetType) {
    _currentFilter = SearchFilter.empty(targetType);
    notifyListeners();
  }

  // 키워드 설정
  void setKeyword(String keyword) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(keyword: keyword.isEmpty ? null : keyword);
      notifyListeners();
    }
  }

  // 카테고리 토글
  void toggleCategory(String category) {
    if (_currentFilter != null) {
      final categories = List<String>.from(_currentFilter!.categories);
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
      _currentFilter = _currentFilter!.copyWith(categories: categories);
      notifyListeners();
    }
  }

  // 지역 토글
  void toggleRegion(String region) {
    if (_currentFilter != null) {
      final regions = List<String>.from(_currentFilter!.regions);
      if (regions.contains(region)) {
        regions.remove(region);
      } else {
        regions.add(region);
      }
      _currentFilter = _currentFilter!.copyWith(regions: regions);
      notifyListeners();
    }
  }

  // 플랫폼 토글
  void togglePlatform(String platform) {
    if (_currentFilter != null) {
      final platforms = List<String>.from(_currentFilter!.platforms);
      if (platforms.contains(platform)) {
        platforms.remove(platform);
      } else {
        platforms.add(platform);
      }
      _currentFilter = _currentFilter!.copyWith(platforms: platforms);
      notifyListeners();
    }
  }

  // 상태 토글
  void toggleStatus(String status) {
    if (_currentFilter != null) {
      final statuses = List<String>.from(_currentFilter!.statuses);
      if (statuses.contains(status)) {
        statuses.remove(status);
      } else {
        statuses.add(status);
      }
      _currentFilter = _currentFilter!.copyWith(statuses: statuses);
      notifyListeners();
    }
  }

  // 가격 범위 설정
  void setPriceRange(PriceRange? priceRange) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(priceRange: priceRange);
      notifyListeners();
    }
  }

  // 팔로워 범위 설정
  void setFollowerRange(FollowerRange? followerRange) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(followerRange: followerRange);
      notifyListeners();
    }
  }

  // 평점 범위 설정
  void setRatingRange(RatingRange? ratingRange) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(ratingRange: ratingRange);
      notifyListeners();
    }
  }

  // 인증 여부 설정
  void setVerifiedFilter(bool? isVerified) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(isVerified: isVerified);
      notifyListeners();
    }
  }

  // 추천 여부 설정
  void setRecommendedFilter(bool? isRecommended) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(isRecommended: isRecommended);
      notifyListeners();
    }
  }

  // 포트폴리오 보유 여부 설정
  void setPortfolioFilter(bool? hasPortfolio) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(hasPortfolio: hasPortfolio);
      notifyListeners();
    }
  }

  // 날짜 범위 설정
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    }
  }

  // 정렬 옵션 설정
  void setSortOption(SortOption sortOption, [bool? descending]) {
    if (_currentFilter != null) {
      _currentFilter = _currentFilter!.copyWith(
        sortOption: sortOption,
        sortDescending: descending ?? _currentFilter!.sortDescending,
      );
      notifyListeners();
    }
  }

  // 필터 초기화
  void clearFilters() {
    if (_currentFilter != null) {
      _currentFilter = SearchFilter.empty(_currentFilter!.targetType);
      _campaignResults = null;
      _influencerResults = null;
      _currentPage = 1;
      _hasMoreResults = false;
      notifyListeners();
    }
  }

  // 필터 적용
  void applyFilter(SearchFilter filter) {
    _currentFilter = filter;
    _currentPage = 1;
    notifyListeners();
    
    // 자동 검색 실행
    performSearch();
  }

  // 검색 실행
  Future<void> performSearch({bool loadMore = false}) async {
    if (_currentFilter == null) return;

    if (!loadMore) {
      _currentPage = 1;
      _isSearching = true;
      _searchError = null;
      notifyListeners();
    }

    try {
      switch (_currentFilter!.targetType) {
        case SearchTargetType.campaign:
          await _searchCampaigns(loadMore);
          break;
        case SearchTargetType.influencer:
          await _searchInfluencers(loadMore);
          break;
        default:
          break;
      }
    } catch (e) {
      _searchError = '검색 중 오류가 발생했습니다: ${e.toString()}';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> _searchCampaigns(bool loadMore) async {
    final result = await _searchService.searchCampaigns(
      filter: _currentFilter!,
      page: _currentPage,
    );

    if (loadMore && _campaignResults != null) {
      final existingItems = _campaignResults!.items;
      _campaignResults = SearchResult<Campaign>(
        items: [...existingItems, ...result.items],
        totalCount: result.totalCount,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        hasMore: result.hasMore,
        appliedFilter: result.appliedFilter,
        searchDuration: result.searchDuration,
      );
    } else {
      _campaignResults = result;
    }

    _searchResults = _campaignResults;
    _hasMoreResults = result.hasMore;
    if (loadMore) _currentPage++;
  }

  Future<void> _searchInfluencers(bool loadMore) async {
    final result = await _searchService.searchInfluencers(
      filter: _currentFilter!,
      page: _currentPage,
    );

    if (loadMore && _influencerResults != null) {
      final existingItems = _influencerResults!.items;
      _influencerResults = SearchResult<User>(
        items: [...existingItems, ...result.items],
        totalCount: result.totalCount,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        hasMore: result.hasMore,
        appliedFilter: result.appliedFilter,
        searchDuration: result.searchDuration,
      );
    } else {
      _influencerResults = result;
    }

    _searchResults = _influencerResults;
    _hasMoreResults = result.hasMore;
    if (loadMore) _currentPage++;
  }

  // 더 많은 결과 로드
  Future<void> loadMoreResults() async {
    if (_hasMoreResults && !_isSearching) {
      await performSearch(loadMore: true);
    }
  }

  // 검색 제안 가져오기
  Future<void> loadSuggestions(String query) async {
    if (_currentFilter == null || query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      _suggestions = await _searchService.getSuggestions(
        query,
        _currentFilter!.targetType,
      );
    } catch (e) {
      _suggestions = [];
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // 인기 검색어 로드
  Future<void> loadPopularKeywords() async {
    if (_currentFilter == null) return;

    try {
      _popularKeywords = await _searchService.getPopularKeywords(
        _currentFilter!.targetType,
      );
      notifyListeners();
    } catch (e) {
      _popularKeywords = [];
    }
  }

  // 저장된 검색 조건 로드
  Future<void> loadSavedSearches(String userId) async {
    if (_currentFilter == null) return;

    _isLoadingSavedSearches = true;
    _savedSearchError = null;
    notifyListeners();

    try {
      _savedSearches = await _searchService.getSavedSearches(
        userId,
        _currentFilter!.targetType,
      );
    } catch (e) {
      _savedSearchError = '저장된 검색 조건을 불러오는데 실패했습니다: ${e.toString()}';
    } finally {
      _isLoadingSavedSearches = false;
      notifyListeners();
    }
  }

  // 검색 조건 저장
  Future<bool> saveCurrentSearch(String userId, String name, String description) async {
    if (_currentFilter == null) return false;

    try {
      final savedSearch = SavedSearch(
        id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        searchFilter: _currentFilter!.copyWith(isSaved: true),
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _searchService.saveSearch(userId, savedSearch);
      
      if (success) {
        // 저장된 검색 목록 새로고침
        await loadSavedSearches(userId);
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // 저장된 검색 삭제
  Future<bool> deleteSavedSearch(String userId, String searchId) async {
    try {
      final success = await _searchService.deleteSavedSearch(userId, searchId);
      
      if (success && _savedSearches != null) {
        _savedSearches!.removeWhere((search) => search.id == searchId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // 저장된 검색 적용
  void applySavedSearch(SavedSearch savedSearch) {
    _currentFilter = savedSearch.searchFilter.copyWith(
      updatedAt: DateTime.now(),
    );
    _currentPage = 1;
    notifyListeners();
    
    // 자동 검색 실행
    performSearch();
  }

  // 프리셋 필터 가져오기
  List<SearchFilter> getPresetFilters() {
    if (_currentFilter == null) return [];
    return _searchService.getPresetFilters(_currentFilter!.targetType);
  }

  // 필터 옵션 가져오기
  Map<String, List<String>> getFilterOptions() {
    if (_currentFilter == null) return {};
    return _searchService.getFilterOptions(_currentFilter!.targetType);
  }

  // 현재 필터의 활성 필터 수
  int get activeFilterCount => _currentFilter?.activeFilterCount ?? 0;

  // 현재 필터에 활성 필터가 있는지
  bool get hasActiveFilters => _currentFilter?.hasActiveFilters ?? false;

  // 검색 결과가 있는지
  bool get hasResults {
    switch (_currentFilter?.targetType) {
      case SearchTargetType.campaign:
        return _campaignResults?.isNotEmpty ?? false;
      case SearchTargetType.influencer:
        return _influencerResults?.isNotEmpty ?? false;
      default:
        return false;
    }
  }

  // 총 검색 결과 수
  int get totalResultCount {
    switch (_currentFilter?.targetType) {
      case SearchTargetType.campaign:
        return _campaignResults?.totalCount ?? 0;
      case SearchTargetType.influencer:
        return _influencerResults?.totalCount ?? 0;
      default:
        return 0;
    }
  }

  // 현재 표시된 결과 수
  int get currentResultCount {
    switch (_currentFilter?.targetType) {
      case SearchTargetType.campaign:
        return _campaignResults?.items.length ?? 0;
      case SearchTargetType.influencer:
        return _influencerResults?.items.length ?? 0;
      default:
        return 0;
    }
  }
}
