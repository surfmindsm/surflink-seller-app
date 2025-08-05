import 'package:flutter/material.dart';

// 검색 대상 타입
enum SearchTargetType {
  campaign,     // 캠페인
  influencer,   // 인플루언서
  seller,       // 판매사
  contract,     // 계약
  review,       // 리뷰
}

// 정렬 옵션
enum SortOption {
  latest,       // 최신순
  oldest,       // 오래된순
  popular,      // 인기순
  rating,       // 평점순
  ratingDesc,   // 평점 낮은순
  priceAsc,     // 가격 낮은순
  priceDesc,    // 가격 높은순
  price,        // 가격순 (별칭)
  followers,    // 팔로워순
  engagement,   // 참여율순
  deadline,     // 마감일순
  alphabet,     // 가나다순
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.latest:
        return '최신순';
      case SortOption.oldest:
        return '오래된순';
      case SortOption.popular:
        return '인기순';
      case SortOption.rating:
        return '평점순';
      case SortOption.ratingDesc:
        return '평점 낮은순';
      case SortOption.priceAsc:
        return '가격 낮은순';
      case SortOption.priceDesc:
        return '가격 높은순';
      case SortOption.price:
        return '가격순';
      case SortOption.followers:
        return '팔로워순';
      case SortOption.engagement:
        return '참여율순';
      case SortOption.deadline:
        return '마감일순';
      case SortOption.alphabet:
        return '가나다순';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.latest:
        return Icons.access_time;
      case SortOption.oldest:
        return Icons.history;
      case SortOption.popular:
        return Icons.trending_up;
      case SortOption.rating:
        return Icons.star;
      case SortOption.ratingDesc:
        return Icons.trending_down;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.price:
        return Icons.attach_money;
      case SortOption.followers:
        return Icons.people;
      case SortOption.engagement:
        return Icons.bar_chart;
      case SortOption.deadline:
        return Icons.alarm;
      case SortOption.alphabet:
        return Icons.sort_by_alpha;
    }
  }
}

// 가격 범위
class PriceRange {
  final double? min;
  final double? max;

  PriceRange({this.min, this.max});

  bool get isEmpty => min == null && max == null;

  bool contains(double price) {
    if (min != null && price < min!) return false;
    if (max != null && price > max!) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
  };

  factory PriceRange.fromJson(Map<String, dynamic> json) => PriceRange(
    min: json['min']?.toDouble(),
    max: json['max']?.toDouble(),
  );

  @override
  String toString() {
    if (isEmpty) return '전체';
    if (min != null && max != null) {
      return '${_formatPrice(min!)} ~ ${_formatPrice(max!)}';
    }
    if (min != null) return '${_formatPrice(min!)} 이상';
    if (max != null) return '${_formatPrice(max!)} 이하';
    return '전체';
  }

  String _formatPrice(double price) {
    if (price >= 10000) {
      return '${(price / 10000).toInt()}만원';
    }
    return '${price.toInt()}원';
  }
}

// 팔로워 범위
class FollowerRange {
  final int? min;
  final int? max;

  FollowerRange({this.min, this.max});

  bool get isEmpty => min == null && max == null;

  bool contains(int followers) {
    if (min != null && followers < min!) return false;
    if (max != null && followers > max!) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
  };

  factory FollowerRange.fromJson(Map<String, dynamic> json) => FollowerRange(
    min: json['min']?.toInt(),
    max: json['max']?.toInt(),
  );

  @override
  String toString() {
    if (isEmpty) return '전체';
    if (min != null && max != null) {
      return '${_formatFollowers(min!)} ~ ${_formatFollowers(max!)}';
    }
    if (min != null) return '${_formatFollowers(min!)} 이상';
    if (max != null) return '${_formatFollowers(max!)} 이하';
    return '전체';
  }

  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      return '${(followers / 10000).toInt()}만';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toInt()}천';
    }
    return '$followers';
  }
}

// 평점 범위
class RatingRange {
  final double? min;
  final double? max;

  RatingRange({this.min, this.max});

  bool get isEmpty => min == null && max == null;

  bool contains(double rating) {
    if (min != null && rating < min!) return false;
    if (max != null && rating > max!) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
  };

  factory RatingRange.fromJson(Map<String, dynamic> json) => RatingRange(
    min: json['min']?.toDouble(),
    max: json['max']?.toDouble(),
  );

  @override
  String toString() {
    if (isEmpty) return '전체';
    if (min != null && max != null) {
      return '${min!.toStringAsFixed(1)}점 ~ ${max!.toStringAsFixed(1)}점';
    }
    if (min != null) return '${min!.toStringAsFixed(1)}점 이상';
    if (max != null) return '${max!.toStringAsFixed(1)}점 이하';
    return '전체';
  }
}

// 검색 필터
class SearchFilter {
  final String id;
  final String name;
  final SearchTargetType targetType;
  
  // 기본 검색
  final String? keyword;
  final List<String> tags;
  
  // 카테고리 필터
  final List<String> categories;
  final List<String> regions;
  final List<String> platforms;
  
  // 범위 필터
  final PriceRange? priceRange;
  final FollowerRange? followerRange;
  final RatingRange? ratingRange;
  
  // 상태 필터
  final List<String> statuses;
  final bool? isVerified;
  final bool? isRecommended;
  final bool? hasPortfolio;
  
  // 날짜 필터
  final DateTime? startDate;
  final DateTime? endDate;
  
  // 정렬
  final SortOption sortOption;
  final bool sortDescending;
  
  // 메타데이터
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSaved;

  SearchFilter({
    required this.id,
    required this.name,
    required this.targetType,
    this.keyword,
    this.tags = const [],
    this.categories = const [],
    this.regions = const [],
    this.platforms = const [],
    this.priceRange,
    this.followerRange,
    this.ratingRange,
    this.statuses = const [],
    this.isVerified,
    this.isRecommended,
    this.hasPortfolio,
    this.startDate,
    this.endDate,
    this.sortOption = SortOption.latest,
    this.sortDescending = true,
    required this.createdAt,
    required this.updatedAt,
    this.isSaved = false,
  });

  bool get hasActiveFilters {
    return keyword?.isNotEmpty == true ||
           tags.isNotEmpty ||
           categories.isNotEmpty ||
           regions.isNotEmpty ||
           platforms.isNotEmpty ||
           priceRange?.isEmpty == false ||
           followerRange?.isEmpty == false ||
           ratingRange?.isEmpty == false ||
           statuses.isNotEmpty ||
           isVerified != null ||
           isRecommended != null ||
           hasPortfolio != null ||
           startDate != null ||
           endDate != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (keyword?.isNotEmpty == true) count++;
    if (tags.isNotEmpty) count++;
    if (categories.isNotEmpty) count++;
    if (regions.isNotEmpty) count++;
    if (platforms.isNotEmpty) count++;
    if (priceRange?.isEmpty == false) count++;
    if (followerRange?.isEmpty == false) count++;
    if (ratingRange?.isEmpty == false) count++;
    if (statuses.isNotEmpty) count++;
    if (isVerified != null) count++;
    if (isRecommended != null) count++;
    if (hasPortfolio != null) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }

  String get sortDisplayName {
    switch (sortOption) {
      case SortOption.latest:
        return '최신순';
      case SortOption.oldest:
        return '오래된순';
      case SortOption.popular:
        return '인기순';
      case SortOption.rating:
        return '평점 높은순';
      case SortOption.ratingDesc:
        return '평점 낮은순';
      case SortOption.priceAsc:
        return '가격 낮은순';
      case SortOption.priceDesc:
        return '가격 높은순';
      case SortOption.price:
        return '가격순';
      case SortOption.followers:
        return '팔로워순';
      case SortOption.engagement:
        return '참여율순';
      case SortOption.deadline:
        return '마감일순';
      case SortOption.alphabet:
        return '가나다순';
    }
  }

  IconData get sortIcon {
    switch (sortOption) {
      case SortOption.latest:
      case SortOption.oldest:
        return Icons.schedule;
      case SortOption.popular:
        return Icons.trending_up;
      case SortOption.rating:
      case SortOption.ratingDesc:
        return Icons.star;
      case SortOption.priceAsc:
      case SortOption.priceDesc:
      case SortOption.price:
        return Icons.attach_money;
      case SortOption.followers:
        return Icons.people;
      case SortOption.engagement:
        return Icons.favorite;
      case SortOption.deadline:
        return Icons.event;
      case SortOption.alphabet:
        return Icons.sort_by_alpha;
    }
  }

  SearchFilter copyWith({
    String? id,
    String? name,
    SearchTargetType? targetType,
    String? keyword,
    List<String>? tags,
    List<String>? categories,
    List<String>? regions,
    List<String>? platforms,
    PriceRange? priceRange,
    FollowerRange? followerRange,
    RatingRange? ratingRange,
    List<String>? statuses,
    bool? isVerified,
    bool? isRecommended,
    bool? hasPortfolio,
    DateTime? startDate,
    DateTime? endDate,
    SortOption? sortOption,
    bool? sortDescending,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaved,
  }) {
    return SearchFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      targetType: targetType ?? this.targetType,
      keyword: keyword ?? this.keyword,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      regions: regions ?? this.regions,
      platforms: platforms ?? this.platforms,
      priceRange: priceRange ?? this.priceRange,
      followerRange: followerRange ?? this.followerRange,
      ratingRange: ratingRange ?? this.ratingRange,
      statuses: statuses ?? this.statuses,
      isVerified: isVerified ?? this.isVerified,
      isRecommended: isRecommended ?? this.isRecommended,
      hasPortfolio: hasPortfolio ?? this.hasPortfolio,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortOption: sortOption ?? this.sortOption,
      sortDescending: sortDescending ?? this.sortDescending,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSaved: isSaved ?? this.isSaved,
    );
  }

  // 빈 필터 생성
  factory SearchFilter.empty(SearchTargetType targetType) {
    final now = DateTime.now();
    return SearchFilter(
      id: 'empty_${now.millisecondsSinceEpoch}',
      name: '기본 검색',
      targetType: targetType,
      createdAt: now,
      updatedAt: now,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target_type': targetType.name,
    'keyword': keyword,
    'tags': tags,
    'categories': categories,
    'regions': regions,
    'platforms': platforms,
    'price_range': priceRange?.toJson(),
    'follower_range': followerRange?.toJson(),
    'rating_range': ratingRange?.toJson(),
    'statuses': statuses,
    'is_verified': isVerified,
    'is_recommended': isRecommended,
    'has_portfolio': hasPortfolio,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'sort_option': sortOption.name,
    'sort_descending': sortDescending,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_saved': isSaved,
  };

  factory SearchFilter.fromJson(Map<String, dynamic> json) => SearchFilter(
    id: json['id'],
    name: json['name'],
    targetType: SearchTargetType.values.firstWhere(
      (e) => e.name == json['target_type'],
      orElse: () => SearchTargetType.campaign,
    ),
    keyword: json['keyword'],
    tags: List<String>.from(json['tags'] ?? []),
    categories: List<String>.from(json['categories'] ?? []),
    regions: List<String>.from(json['regions'] ?? []),
    platforms: List<String>.from(json['platforms'] ?? []),
    priceRange: json['price_range'] != null 
        ? PriceRange.fromJson(json['price_range'])
        : null,
    followerRange: json['follower_range'] != null
        ? FollowerRange.fromJson(json['follower_range'])
        : null,
    ratingRange: json['rating_range'] != null
        ? RatingRange.fromJson(json['rating_range'])
        : null,
    statuses: List<String>.from(json['statuses'] ?? []),
    isVerified: json['is_verified'],
    isRecommended: json['is_recommended'],
    hasPortfolio: json['has_portfolio'],
    startDate: json['start_date'] != null 
        ? DateTime.parse(json['start_date'])
        : null,
    endDate: json['end_date'] != null
        ? DateTime.parse(json['end_date'])
        : null,
    sortOption: SortOption.values.firstWhere(
      (e) => e.name == json['sort_option'],
      orElse: () => SortOption.latest,
    ),
    sortDescending: json['sort_descending'] ?? true,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    isSaved: json['is_saved'] ?? false,
  );
}

// 검색 결과
class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final SearchFilter appliedFilter;
  final Duration searchDuration;

  SearchResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    required this.appliedFilter,
    required this.searchDuration,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'total_count': totalCount,
    'current_page': currentPage,
    'total_pages': totalPages,
    'has_more': hasMore,
    'applied_filter': appliedFilter.toJson(),
    'search_duration_ms': searchDuration.inMilliseconds,
  };
}

// 저장된 검색 조건
class SavedSearch {
  final String id;
  final String name;
  final String? description;
  final SearchFilter searchFilter;
  final int useCount;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime updatedAt;

  SavedSearch({
    required this.id,
    required this.name,
    this.description,
    required this.searchFilter,
    this.useCount = 0,
    required this.createdAt,
    this.lastUsedAt,
    required this.updatedAt,
  });

  // 아이콘 getter
  IconData get icon {
    switch (searchFilter.targetType) {
      case SearchTargetType.campaign:
        return Icons.campaign;
      case SearchTargetType.influencer:
        return Icons.person;
      case SearchTargetType.seller:
        return Icons.store;
      case SearchTargetType.contract:
        return Icons.description;
      case SearchTargetType.review:
        return Icons.star;
    }
  }

  SavedSearch copyWith({
    String? id,
    String? name,
    String? description,
    SearchFilter? searchFilter,
    int? useCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? updatedAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      searchFilter: searchFilter ?? this.searchFilter,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'search_filter': searchFilter.toJson(),
    'use_count': useCount,
    'created_at': createdAt.toIso8601String(),
    'last_used_at': lastUsedAt?.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    searchFilter: SearchFilter.fromJson(json['search_filter']),
    useCount: json['use_count'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
    lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at']) : null,
    updatedAt: DateTime.parse(json['updated_at']),
  );
}
