import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/search_filter_model.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/filter_chip_widget.dart';
import '../../widgets/search/saved_search_widget.dart';
import '../../widgets/campaign/campaign_card.dart';
import '../../widgets/influencer/influencer_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final SearchTargetType targetType;

  const SearchResultsScreen({
    Key? key,
    required this.targetType,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
      _searchController.text = searchProvider.currentFilter?.keyword ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
      if (!searchProvider.isLoadingMore && searchProvider.hasMoreResults) {
        searchProvider.loadMoreResults();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<SearchFilterProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              _buildSearchHeader(searchProvider),
              _buildFilterSummary(searchProvider),
              Expanded(
                child: _buildSearchResults(searchProvider),
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
      title: Text('${_getTargetTypeLabel()} 검색결과'),
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
        PopupMenuButton<String>(
          onSelected: (value) async {
            final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
            
            switch (value) {
              case 'save':
                await _showSaveFilterDialog(searchProvider);
                break;
              case 'clear':
                searchProvider.clearFilters();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.bookmark_add),
                  SizedBox(width: 8),
                  Text('검색 조건 저장'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('필터 초기화'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchHeader(SearchFilterProvider searchProvider) {
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

          // 정렬 옵션
          Row(
            children: [
              const Text(
                '정렬:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildSortOptions(searchProvider),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(SearchFilterProvider searchProvider) {
    if (!searchProvider.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '활성 필터 (${searchProvider.activeFilterCount})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  searchProvider.clearFilters();
                  _performSearch();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('모두 제거'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildActiveFilterChips(searchProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchFilterProvider searchProvider) {
    if (searchProvider.isSearching && (searchProvider.searchResults?.isEmpty ?? true)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('검색 중...'),
          ],
        ),
      );
    }

    if (searchProvider.searchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchProvider.searchError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final results = searchProvider.searchResults;
    final totalCount = searchProvider.totalResultCount;

    if (results?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어나 필터 조건을 시도해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                searchProvider.clearFilters();
                _searchController.clear();
              },
              child: const Text('필터 초기화'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 결과 요약
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '총 ${_formatNumber(totalCount)}개의 결과',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (searchProvider.hasMoreResults)
                Text(
                  '${results?.items.length ?? 0}개 표시',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),

        // 결과 리스트
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: (results?.items.length ?? 0) + (searchProvider.hasMoreResults ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == (results?.items.length ?? 0)) {
                return _buildLoadMoreIndicator(searchProvider);
              }

              final item = results?.items[index];
              if (item == null) return const SizedBox.shrink();
              return _buildResultItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(dynamic item) {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return CampaignCard(
          campaign: item,
          onTap: () => _navigateToCampaignDetail(item.id),
        );
      case SearchTargetType.influencer:
        return InfluencerCard(
          influencer: item,
          onTap: () => _navigateToInfluencerProfile(item.id),
        );
      default:
        return ListTile(
          title: Text(item.toString()),
        );
    }
  }

  Widget _buildLoadMoreIndicator(SearchFilterProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: searchProvider.isLoadingMore
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => searchProvider.loadMoreResults(),
                child: const Text('더 보기'),
              ),
      ),
    );
  }

  List<Widget> _buildSortOptions(SearchFilterProvider searchProvider) {
    final sortOptions = _getRelevantSortOptions();
    final currentSort = searchProvider.currentFilter?.sortOption ?? SortOption.latest;

    return sortOptions.map((option) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SearchChipWidget(
          label: option.displayName,
          icon: option.icon,
          isSelected: currentSort == option,
          onTap: () {
            searchProvider.setSortOption(option);
            _performSearch();
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildActiveFilterChips(SearchFilterProvider searchProvider) {
    final chips = <Widget>[];
    final filter = searchProvider.currentFilter!;

    // 키워드
    if (filter.keyword?.isNotEmpty == true) {
      chips.add(FilterChipWidget(
        label: '"${filter.keyword}"',
        icon: Icons.search,
        onDeleted: () {
          _searchController.clear();
          searchProvider.setKeyword('');
          _performSearch();
        },
      ));
    }

    // 카테고리
    for (final category in filter.categories) {
      chips.add(FilterChipWidget(
        label: category,
        icon: Icons.category,
        onDeleted: () {
          searchProvider.toggleCategory(category);
          _performSearch();
        },
      ));
    }

    // 지역
    for (final region in filter.regions) {
      chips.add(FilterChipWidget(
        label: region,
        icon: Icons.location_on,
        onDeleted: () {
          searchProvider.toggleRegion(region);
          _performSearch();
        },
      ));
    }

    // 플랫폼
    for (final platform in filter.platforms) {
      chips.add(FilterChipWidget(
        label: platform,
        icon: Icons.devices,
        onDeleted: () {
          searchProvider.togglePlatform(platform);
          _performSearch();
        },
      ));
    }

    // 가격 범위
    if (filter.priceRange?.isEmpty == false) {
      chips.add(FilterChipWidget(
        label: filter.priceRange.toString(),
        icon: Icons.attach_money,
        onDeleted: () {
          searchProvider.setPriceRange(null);
          _performSearch();
        },
      ));
    }

    // 팔로워 범위
    if (filter.followerRange?.isEmpty == false) {
      chips.add(FilterChipWidget(
        label: filter.followerRange.toString(),
        icon: Icons.people,
        onDeleted: () {
          searchProvider.setFollowerRange(null);
          _performSearch();
        },
      ));
    }

    // 평점 범위
    if (filter.ratingRange?.isEmpty == false) {
      chips.add(FilterChipWidget(
        label: '${filter.ratingRange!.min?.toStringAsFixed(1) ?? '0'}-${filter.ratingRange!.max?.toStringAsFixed(1) ?? '5'}★',
        icon: Icons.star,
        onDeleted: () {
          searchProvider.setRatingRange(null);
          _performSearch();
        },
      ));
    }

    return chips;
  }

  Widget _buildFloatingActionButton() {
    return Consumer<SearchFilterProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchResults?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton.extended(
          onPressed: () => _scrollToTop(),
          icon: const Icon(Icons.keyboard_arrow_up),
          label: const Text('맨 위로'),
        );
      },
    );
  }

  List<SortOption> _getRelevantSortOptions() {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return [
          SortOption.latest,
          SortOption.deadline,
          SortOption.price,
          SortOption.popular,
        ];
      case SearchTargetType.influencer:
        return [
          SortOption.latest,
          SortOption.followers,
          SortOption.engagement,
          SortOption.rating,
        ];
      default:
        return [SortOption.latest, SortOption.popular];
    }
  }

  String _getTargetTypeLabel() {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return '캠페인';
      case SearchTargetType.influencer:
        return '인플루언서';
      default:
        return '검색';
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

  IconData _getEmptyIcon() {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return Icons.campaign;
      case SearchTargetType.influencer:
        return Icons.person;
      default:
        return Icons.search_off;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _openFilterSettings() {
    context.push('/search/filter-settings?targetType=${widget.targetType.name}');
  }

  void _performSearch() {
    final searchProvider = Provider.of<SearchFilterProvider>(context, listen: false);
    searchProvider.performSearch();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToCampaignDetail(String campaignId) {
    context.push('/campaign/$campaignId');
  }

  void _navigateToInfluencerProfile(String influencerId) {
    context.push('/profile/$influencerId');
  }

  Future<void> _showSaveFilterDialog(SearchFilterProvider searchProvider) async {
    if (!searchProvider.hasActiveFilters) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장할 필터 조건이 없습니다'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SaveSearchDialogWidget(
        searchFilter: searchProvider.currentFilter!,
        onSave: (name) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.user != null) {
            final success = await searchProvider.saveCurrentSearch(
              authProvider.user!.id,
              name,
              '현재 검색 조건으로 저장된 검색입니다.',
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '검색 조건이 저장되었습니다' : '저장에 실패했습니다'),
                  backgroundColor: success ? null : Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
