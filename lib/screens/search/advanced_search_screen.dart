import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/search_filter_model.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/filter_chip_widget.dart';
import '../../widgets/search/saved_search_widget.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final SearchTargetType targetType;
  final String? initialKeyword;

  const AdvancedSearchScreen({
    Key? key,
    required this.targetType,
    this.initialKeyword,
  }) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
      searchProvider.initializeFilter(widget.targetType);
      
      if (widget.initialKeyword != null) {
        searchProvider.setKeyword(widget.initialKeyword!);
      }
      
      // 인기 검색어와 저장된 검색 로드
      searchProvider.loadPopularKeywords();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        searchProvider.loadSavedSearches(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<SearchFilterProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              _buildSearchSection(searchProvider),
              _buildTabSection(),
              Expanded(
                child: _buildTabContent(searchProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getScreenTitle()),
      actions: [
        Consumer<SearchFilterProvider>(
          builder: (context, searchProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _openFilterSettings(),
                ),
                if (searchProvider.hasActiveFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${searchProvider.activeFilterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection(SearchFilterProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 검색바
          SearchBarWidget(
            controller: _searchController,
            hintText: _getSearchHint(),
            onChanged: (value) {
              searchProvider.setKeyword(value);
              if (value.isNotEmpty) {
                searchProvider.loadSuggestions(value);
              }
            },
            onSubmitted: (value) {
              _performSearch();
            },
            suggestions: searchProvider.suggestions,
            onSuggestionSelected: (suggestion) {
              _searchController.text = suggestion;
              searchProvider.setKeyword(suggestion);
              _performSearch();
            },
          ),

          const SizedBox(height: 12),

          // 활성 필터 칩들
          if (searchProvider.hasActiveFilters) ...[
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildActiveFilterChips(searchProvider),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 검색 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: searchProvider.isSearching ? null : _performSearch,
                  icon: searchProvider.isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(searchProvider.isSearching ? '검색 중...' : '검색'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  searchProvider.clearFilters();
                  _searchController.clear();
                },
                child: const Text('초기화'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '빠른 필터'),
          Tab(text: '저장된 검색'),
          Tab(text: '인기 검색어'),
        ],
      ),
    );
  }

  Widget _buildTabContent(SearchFilterProvider searchProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildQuickFiltersTab(searchProvider),
        _buildSavedSearchesTab(searchProvider),
        _buildPopularKeywordsTab(searchProvider),
      ],
    );
  }

  Widget _buildQuickFiltersTab(SearchFilterProvider searchProvider) {
    final filterOptions = searchProvider.getFilterOptions();
    final presetFilters = searchProvider.getPresetFilters();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 프리셋 필터
        if (presetFilters.isNotEmpty) ...[
          _buildSectionHeader('추천 필터', Icons.auto_awesome),
          const SizedBox(height: 8),
          ...presetFilters.map((preset) => _buildPresetFilterCard(preset, searchProvider)),
          const SizedBox(height: 24),
        ],

        // 카테고리 필터
        if (filterOptions['categories']?.isNotEmpty == true) ...[
          _buildSectionHeader('카테고리', Icons.category),
          const SizedBox(height: 8),
          _buildFilterChipGrid(
            filterOptions['categories']!,
            searchProvider.currentFilter?.categories ?? [],
            (category) => searchProvider.toggleCategory(category),
          ),
          const SizedBox(height: 24),
        ],

        // 지역 필터
        if (filterOptions['regions']?.isNotEmpty == true) ...[
          _buildSectionHeader('지역', Icons.location_on),
          const SizedBox(height: 8),
          _buildFilterChipGrid(
            filterOptions['regions']!,
            searchProvider.currentFilter?.regions ?? [],
            (region) => searchProvider.toggleRegion(region),
          ),
          const SizedBox(height: 24),
        ],

        // 플랫폼 필터
        if (filterOptions['platforms']?.isNotEmpty == true) ...[
          _buildSectionHeader('플랫폼', Icons.devices),
          const SizedBox(height: 8),
          _buildFilterChipGrid(
            filterOptions['platforms']!,
            searchProvider.currentFilter?.platforms ?? [],
            (platform) => searchProvider.togglePlatform(platform),
          ),
          const SizedBox(height: 24),
        ],

        // 상태 필터 (캠페인 전용)
        if (widget.targetType == SearchTargetType.campaign && 
            filterOptions['statuses']?.isNotEmpty == true) ...[
          _buildSectionHeader('상태', Icons.flag),
          const SizedBox(height: 8),
          _buildFilterChipGrid(
            filterOptions['statuses']!,
            searchProvider.currentFilter?.statuses ?? [],
            (status) => searchProvider.toggleStatus(status),
          ),
          const SizedBox(height: 24),
        ],

        // 특별 필터 (인플루언서 전용)
        if (widget.targetType == SearchTargetType.influencer) ...[
          _buildSectionHeader('특별 조건', Icons.star),
          const SizedBox(height: 8),
          _buildSpecialFilters(searchProvider),
        ],
      ],
    );
  }

  Widget _buildSavedSearchesTab(SearchFilterProvider searchProvider) {
    if (searchProvider.isLoadingSavedSearches) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.savedSearchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(searchProvider.savedSearchError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.user != null) {
                  searchProvider.loadSavedSearches(authProvider.user!.id);
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final savedSearches = searchProvider.savedSearches ?? [];
    if (savedSearches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '저장된 검색 조건이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '자주 사용하는 검색 조건을 저장해보세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedSearches.length,
      itemBuilder: (context, index) {
        final savedSearch = savedSearches[index];
        return SavedSearchWidget(
          savedSearch: savedSearch,
          onTap: () {
            searchProvider.applySavedSearch(savedSearch);
            _navigateToResults();
          },
          onDelete: () => _deleteSavedSearch(savedSearch, searchProvider),
        );
      },
    );
  }

  Widget _buildPopularKeywordsTab(SearchFilterProvider searchProvider) {
    final popularKeywords = searchProvider.popularKeywords;
    
    if (popularKeywords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '인기 검색어가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('실시간 인기 검색어', Icons.trending_up),
        const SizedBox(height: 16),
        ...popularKeywords.asMap().entries.map((entry) {
          final index = entry.key;
          final keyword = entry.value;
          return _buildPopularKeywordItem(index + 1, keyword, searchProvider);
        }).toList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChipGrid(
    List<String> options,
    List<String> selectedOptions,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onToggle(option),
          backgroundColor: Colors.grey[100],
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildPresetFilterCard(SearchFilter preset, SearchFilterProvider searchProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(preset.sortIcon, color: Theme.of(context).primaryColor),
        title: Text(preset.name),
        subtitle: Text('${preset.sortDisplayName} • 빠른 적용'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          searchProvider.applyFilter(preset);
          _navigateToResults();
        },
      ),
    );
  }

  Widget _buildSpecialFilters(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    
    return Column(
      children: [
        SwitchListTile(
          title: const Text('인증된 계정만'),
          subtitle: const Text('공식 인증을 받은 인플루언서'),
          value: currentFilter?.isVerified ?? false,
          onChanged: (value) {
            searchProvider.setVerifiedFilter(value);
          },
        ),
        SwitchListTile(
          title: const Text('추천 인플루언서'),
          subtitle: const Text('높은 평점과 좋은 리뷰를 받은 인플루언서'),
          value: currentFilter?.isRecommended ?? false,
          onChanged: (value) {
            searchProvider.setRecommendedFilter(value);
          },
        ),
        SwitchListTile(
          title: const Text('포트폴리오 보유'),
          subtitle: const Text('포트폴리오를 등록한 인플루언서'),
          value: currentFilter?.hasPortfolio ?? false,
          onChanged: (value) {
            searchProvider.setPortfolioFilter(value);
          },
        ),
      ],
    );
  }

  Widget _buildPopularKeywordItem(int rank, String keyword, SearchFilterProvider searchProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? Colors.orange : Colors.grey[200],
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
        title: Text(keyword),
        trailing: const Icon(Icons.search, size: 20),
        onTap: () {
          _searchController.text = keyword;
          searchProvider.setKeyword(keyword);
          _performSearch();
        },
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(SearchFilterProvider searchProvider) {
    final chips = <Widget>[];
    final filter = searchProvider.currentFilter!;

    // 키워드
    if (filter.keyword?.isNotEmpty == true) {
      chips.add(FilterChipWidget(
        label: '"${filter.keyword}"',
        onDeleted: () {
          _searchController.clear();
          searchProvider.setKeyword('');
        },
      ));
    }

    // 카테고리
    for (final category in filter.categories) {
      chips.add(FilterChipWidget(
        label: category,
        onDeleted: () => searchProvider.toggleCategory(category),
      ));
    }

    // 지역
    for (final region in filter.regions) {
      chips.add(FilterChipWidget(
        label: region,
        onDeleted: () => searchProvider.toggleRegion(region),
      ));
    }

    // 가격 범위
    if (filter.priceRange?.isEmpty == false) {
      chips.add(FilterChipWidget(
        label: filter.priceRange.toString(),
        onDeleted: () => searchProvider.setPriceRange(null),
      ));
    }

    // 팔로워 범위
    if (filter.followerRange?.isEmpty == false) {
      chips.add(FilterChipWidget(
        label: filter.followerRange.toString(),
        onDeleted: () => searchProvider.setFollowerRange(null),
      ));
    }

    return chips;
  }

  Widget _buildFloatingActionButton() {
    return Consumer<SearchFilterProvider>(
      builder: (context, searchProvider, child) {
        if (!searchProvider.hasActiveFilters) return const SizedBox();
        
        return FloatingActionButton.extended(
          onPressed: _performSearch,
          icon: const Icon(Icons.search),
          label: Text('${searchProvider.activeFilterCount}개 필터로 검색'),
        );
      },
    );
  }

  String _getScreenTitle() {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return '캠페인 검색';
      case SearchTargetType.influencer:
        return '인플루언서 검색';
      default:
        return '고급 검색';
    }
  }

  String _getSearchHint() {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return '캠페인명, 브랜드명, 키워드 검색...';
      case SearchTargetType.influencer:
        return '인플루언서명, 닉네임, 카테고리 검색...';
      default:
        return '검색어를 입력하세요...';
    }
  }

  void _openFilterSettings() {
    context.push('/search/filter-settings?targetType=${widget.targetType.name}');
  }

  void _performSearch() {
    final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
    if (searchProvider.currentFilter != null) {
      searchProvider.performSearch().then((_) {
        if (searchProvider.searchError == null) {
          _navigateToResults();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(searchProvider.searchError!),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  void _navigateToResults() {
    context.push('/search/results?targetType=${widget.targetType.name}');
  }

  Future<void> _deleteSavedSearch(SavedSearch savedSearch, SearchFilterProvider searchProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 검색 삭제'),
        content: Text('\'${savedSearch.name}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final success = await searchProvider.deleteSavedSearch(
          authProvider.user!.id,
          savedSearch.id,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '저장된 검색이 삭제되었습니다' : '삭제에 실패했습니다'),
              backgroundColor: success ? null : Colors.red,
            ),
          );
        }
      }
    }
  }
}
