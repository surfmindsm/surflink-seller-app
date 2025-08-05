import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/search_filter_model.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/search/saved_search_widget.dart';

class FilterSettingsScreen extends StatefulWidget {
  final SearchTargetType targetType;

  const FilterSettingsScreen({
    Key? key,
    required this.targetType,
  }) : super(key: key);

  @override
  State<FilterSettingsScreen> createState() => _FilterSettingsScreenState();
}

class _FilterSettingsScreenState extends State<FilterSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.targetType == SearchTargetType.influencer ? 4 : 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              _buildTabBar(),
              Expanded(
                child: _buildTabBarView(searchProvider),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('${_getTargetTypeLabel()} 상세 필터'),
      actions: [
        Consumer<SearchFilterProvider>(
          builder: (context, searchProvider, child) {
            if (searchProvider.hasActiveFilters) {
              return TextButton(
                onPressed: () {
                  searchProvider.clearFilters();
                },
                child: const Text('초기화'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = <Tab>[];
    tabs.add(const Tab(text: '기본 필터'));
    tabs.add(const Tab(text: '범위 설정'));
    tabs.add(const Tab(text: '정렬'));
    
    if (widget.targetType == SearchTargetType.influencer) {
      tabs.add(const Tab(text: '특별 조건'));
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: tabs,
        isScrollable: tabs.length > 3,
      ),
    );
  }

  Widget _buildTabBarView(SearchFilterProvider searchProvider) {
    final views = <Widget>[];
    views.add(_buildBasicFiltersTab(searchProvider));
    views.add(_buildRangeFiltersTab(searchProvider));
    views.add(_buildSortingTab(searchProvider));
    
    if (widget.targetType == SearchTargetType.influencer) {
      views.add(_buildSpecialFiltersTab(searchProvider));
    }
    
    return TabBarView(
      controller: _tabController,
      children: views,
    );
  }

  Widget _buildBasicFiltersTab(SearchFilterProvider searchProvider) {
    final filterOptions = searchProvider.getFilterOptions();
    final currentFilter = searchProvider.currentFilter;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 카테고리
        if (filterOptions['categories']?.isNotEmpty == true) ...[
          _buildFilterSection(
            title: '카테고리',
            icon: Icons.category,
            child: _buildMultiSelectGrid(
              options: filterOptions['categories']!,
              selectedOptions: currentFilter?.categories ?? [],
              onToggle: (option) => searchProvider.toggleCategory(option),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 지역
        if (filterOptions['regions']?.isNotEmpty == true) ...[
          _buildFilterSection(
            title: '지역',
            icon: Icons.location_on,
            child: _buildMultiSelectGrid(
              options: filterOptions['regions']!,
              selectedOptions: currentFilter?.regions ?? [],
              onToggle: (option) => searchProvider.toggleRegion(option),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 플랫폼
        if (filterOptions['platforms']?.isNotEmpty == true) ...[
          _buildFilterSection(
            title: '플랫폼',
            icon: Icons.devices,
            child: _buildMultiSelectGrid(
              options: filterOptions['platforms']!,
              selectedOptions: currentFilter?.platforms ?? [],
              onToggle: (option) => searchProvider.togglePlatform(option),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 상태 (캠페인 전용)
        if (widget.targetType == SearchTargetType.campaign && 
            filterOptions['statuses']?.isNotEmpty == true) ...[
          _buildFilterSection(
            title: '상태',
            icon: Icons.flag,
            child: _buildMultiSelectGrid(
              options: filterOptions['statuses']!,
              selectedOptions: currentFilter?.statuses ?? [],
              onToggle: (option) => searchProvider.toggleStatus(option),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRangeFiltersTab(SearchFilterProvider searchProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 가격 범위
        _buildFilterSection(
          title: '가격 범위',
          icon: Icons.attach_money,
          child: _buildPriceRangeSlider(searchProvider),
        ),
        const SizedBox(height: 32),

        // 팔로워 수 범위 (인플루언서 검색시)
        if (widget.targetType == SearchTargetType.influencer) ...[
          _buildFilterSection(
            title: '팔로워 수',
            icon: Icons.people,
            child: _buildFollowerRangeSlider(searchProvider),
          ),
          const SizedBox(height: 32),
        ],

        // 평점 범위
        _buildFilterSection(
          title: '평점',
          icon: Icons.star,
          child: _buildRatingRangeSlider(searchProvider),
        ),
        const SizedBox(height: 32),

        // 날짜 범위
        _buildFilterSection(
          title: '날짜 범위',
          icon: Icons.date_range,
          child: _buildDateRangePicker(searchProvider),
        ),
      ],
    );
  }

  Widget _buildSortingTab(SearchFilterProvider searchProvider) {
    final sortOptions = SortOption.values;
    final currentSort = searchProvider.currentFilter?.sortOption ?? SortOption.latest;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterSection(
          title: '정렬 방식',
          icon: Icons.sort,
          child: Column(
            children: sortOptions.map((option) {
              if (!_isSortOptionRelevant(option)) return const SizedBox.shrink();
              
              return _buildSortOptionTile(
                option: option,
                isSelected: currentSort == option,
                onTap: () => searchProvider.setSortOption(option),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialFiltersTab(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterSection(
          title: '계정 상태',
          icon: Icons.verified,
          child: Column(
            children: [
              _buildSwitchTile(
                title: '인증된 계정만',
                subtitle: '공식 인증을 받은 인플루언서',
                value: currentFilter?.isVerified ?? false,
                onChanged: (value) => searchProvider.setVerifiedFilter(value),
                icon: Icons.verified,
              ),
              _buildSwitchTile(
                title: '추천 인플루언서',
                subtitle: '높은 평점과 좋은 리뷰를 받은 인플루언서',
                value: currentFilter?.isRecommended ?? false,
                onChanged: (value) => searchProvider.setRecommendedFilter(value),
                icon: Icons.star,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildFilterSection(
          title: '콘텐츠',
          icon: Icons.photo_library,
          child: Column(
            children: [
              _buildSwitchTile(
                title: '포트폴리오 보유',
                subtitle: '포트폴리오를 등록한 인플루언서',
                value: currentFilter?.hasPortfolio ?? false,
                onChanged: (value) => searchProvider.setPortfolioFilter(value),
                icon: Icons.folder,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildMultiSelectGrid({
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onToggle,
  }) {
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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    final priceRange = currentFilter?.priceRange;
    final minPrice = priceRange?.min ?? 0;
    final maxPrice = priceRange?.max ?? 1000000;
    
    return Column(
      children: [
        Text(
          '${_formatPrice(minPrice.toInt())} - ${_formatPrice(maxPrice.toInt())}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(minPrice, maxPrice),
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            _formatPrice(minPrice.toInt()),
            _formatPrice(maxPrice.toInt()),
          ),
          onChanged: (values) {
            searchProvider.setPriceRange(PriceRange(
              min: values.start,
              max: values.end,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildFollowerRangeSlider(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    final followerRange = currentFilter?.followerRange;
    final minFollowers = followerRange?.min ?? 0;
    final maxFollowers = followerRange?.max ?? 1000000;
    
    return Column(
      children: [
        Text(
          '${_formatFollowers(minFollowers.toInt())} - ${_formatFollowers(maxFollowers.toInt())}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(minFollowers.toDouble(), maxFollowers.toDouble()),
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            _formatFollowers(minFollowers.toInt()),
            _formatFollowers(maxFollowers.toInt()),
          ),
          onChanged: (values) {
            searchProvider.setFollowerRange(FollowerRange(
              min: values.start.toInt(),
              max: values.end.toInt(),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildRatingRangeSlider(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    final ratingRange = currentFilter?.ratingRange;
    final minRating = ratingRange?.min ?? 0.0;
    final maxRating = ratingRange?.max ?? 5.0;
    
    return Column(
      children: [
        Text(
          '${minRating.toStringAsFixed(1)} - ${maxRating.toStringAsFixed(1)} 점',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(minRating, maxRating),
          min: 0.0,
          max: 5.0,
          divisions: 50,
          labels: RangeLabels(
            minRating.toStringAsFixed(1),
            maxRating.toStringAsFixed(1),
          ),
          onChanged: (values) {
            searchProvider.setRatingRange(RatingRange(
              min: values.start,
              max: values.end,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(SearchFilterProvider searchProvider) {
    final currentFilter = searchProvider.currentFilter;
    final startDate = currentFilter?.startDate;
    final endDate = currentFilter?.endDate;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectStartDate(searchProvider),
                icon: const Icon(Icons.calendar_today),
                label: Text(startDate != null 
                    ? _formatDate(startDate)
                    : '시작일 선택'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectEndDate(searchProvider),
                icon: const Icon(Icons.calendar_today),
                label: Text(endDate != null 
                    ? _formatDate(endDate)
                    : '종료일 선택'),
              ),
            ),
          ],
        ),
        if (startDate != null || endDate != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => searchProvider.setDateRange(null, null),
            child: const Text('날짜 범위 초기화'),
          ),
        ],
      ],
    );
  }

  Widget _buildSortOptionTile({
    required SortOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        option.icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(
        option.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected 
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: value ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<SearchFilterProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: searchProvider.hasActiveFilters
                      ? () => _showSaveFilterDialog(searchProvider)
                      : null,
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('필터 저장'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.done),
                  label: Text(searchProvider.hasActiveFilters
                      ? '필터 적용 (${searchProvider.activeFilterCount})'
                      : '완료'),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  bool _isSortOptionRelevant(SortOption option) {
    switch (widget.targetType) {
      case SearchTargetType.campaign:
        return [
          SortOption.latest,
          SortOption.oldest,
          SortOption.deadline,
          SortOption.price,
          SortOption.popular,
        ].contains(option);
      case SearchTargetType.influencer:
        return [
          SortOption.latest,
          SortOption.oldest,
          SortOption.followers,
          SortOption.engagement,
          SortOption.rating,
          SortOption.alphabet,
        ].contains(option);
      default:
        return true;
    }
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(0)}M원';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K원';
    }
    return '${price}원';
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(0)}K';
    }
    return followers.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectStartDate(SearchFilterProvider searchProvider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: searchProvider.currentFilter?.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      searchProvider.setDateRange(
        picked,
        searchProvider.currentFilter?.endDate,
      );
    }
  }

  Future<void> _selectEndDate(SearchFilterProvider searchProvider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: searchProvider.currentFilter?.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      searchProvider.setDateRange(
        searchProvider.currentFilter?.startDate,
        picked,
      );
    }
  }

  void _showSaveFilterDialog(SearchFilterProvider searchProvider) {
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
              '현재 필터 설정으로 저장된 검색입니다.',
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '필터가 저장되었습니다' : '저장에 실패했습니다'),
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
