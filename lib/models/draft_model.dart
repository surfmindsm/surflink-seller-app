import 'package:flutter/material.dart';

/// 임시저장 타입
enum DraftType {
  campaign,        // 캠페인
  profile,         // 프로필  
  review,          // 리뷰
  message,         // 메시지
  contract,        // 계약서
  proposal,        // 제안서
  portfolio,       // 포트폴리오
  settings,        // 설정
}

/// 임시저장 데이터
class Draft {
  final String id;
  final String userId;
  final DraftType type;
  final String title;
  final String content;
  final Map<String, dynamic> metadata;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime lastSavedAt;
  final bool isAutosaved;

  Draft({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.metadata,
    this.tags,
    required this.createdAt,
    required this.lastSavedAt,
    this.isAutosaved = false,
  });

  /// 타입 이름
  String get typeName {
    switch (type) {
      case DraftType.campaign:
        return '캠페인';
      case DraftType.profile:
        return '프로필';
      case DraftType.review:
        return '리뷰';
      case DraftType.message:
        return '메시지';
      case DraftType.contract:
        return '계약서';
      case DraftType.proposal:
        return '제안서';
      case DraftType.portfolio:
        return '포트폴리오';
      case DraftType.settings:
        return '설정';
    }
  }

  /// 타입 아이콘
  IconData get typeIcon {
    switch (type) {
      case DraftType.campaign:
        return Icons.campaign;
      case DraftType.profile:
        return Icons.person;
      case DraftType.review:
        return Icons.star;
      case DraftType.message:
        return Icons.message;
      case DraftType.contract:
        return Icons.description;
      case DraftType.proposal:
        return Icons.assignment;
      case DraftType.portfolio:
        return Icons.work;
      case DraftType.settings:
        return Icons.settings;
    }
  }

  /// 타입 색상
  Color get typeColor {
    switch (type) {
      case DraftType.campaign:
        return Colors.blue;
      case DraftType.profile:
        return Colors.green;
      case DraftType.review:
        return Colors.orange;
      case DraftType.message:
        return Colors.purple;
      case DraftType.contract:
        return Colors.indigo;
      case DraftType.proposal:
        return Colors.teal;
      case DraftType.portfolio:
        return Colors.pink;
      case DraftType.settings:
        return Colors.grey;
    }
  }

  /// 마지막 저장으로부터 경과 시간
  Duration get timeSinceLastSave {
    return DateTime.now().difference(lastSavedAt);
  }

  /// 저장 시간 텍스트
  String get lastSavedText {
    final duration = timeSinceLastSave;
    
    if (duration.inMinutes < 1) {
      return '방금 전 저장됨';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}분 전 저장됨';
    } else if (duration.inDays < 1) {
      return '${duration.inHours}시간 전 저장됨';
    } else {
      return '${duration.inDays}일 전 저장됨';
    }
  }

  /// 자동저장 여부 텍스트
  String get saveTypeText {
    return isAutosaved ? '자동저장' : '수동저장';
  }

  /// 미리보기 텍스트 (첫 100자)
  String get previewText {
    if (content.isEmpty) return '내용 없음';
    
    final cleanContent = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanContent.length <= 100) {
      return cleanContent;
    }
    
    return '${cleanContent.substring(0, 97)}...';
  }

  /// 복사본 생성
  Draft copyWith({
    String? id,
    String? userId,
    DraftType? type,
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastSavedAt,
    bool? isAutosaved,
  }) {
    return Draft(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      tags: tags ?? (this.tags != null ? List<String>.from(this.tags!) : null),
      createdAt: createdAt ?? this.createdAt,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      isAutosaved: isAutosaved ?? this.isAutosaved,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'metadata': metadata,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'last_saved_at': lastSavedAt.toIso8601String(),
      'is_autosaved': isAutosaved,
    };
  }

  /// JSON 역직렬화
  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'],
      userId: json['user_id'],
      type: DraftType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DraftType.campaign,
      ),
      title: json['title'],
      content: json['content'],
      metadata: Map<String, dynamic>.from(json['metadata']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['created_at']),
      lastSavedAt: DateTime.parse(json['last_saved_at']),
      isAutosaved: json['is_autosaved'] ?? false,
    );
  }

  /// 특정 메타데이터 값 가져오기
  T? getMetadata<T>(String key) {
    return metadata[key] as T?;
  }

  /// 메타데이터 설정
  Draft setMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    
    return copyWith(
      metadata: newMetadata,
      lastSavedAt: DateTime.now(),
    );
  }

  /// 태그 추가
  Draft addTag(String tag) {
    final currentTags = tags ?? <String>[];
    if (!currentTags.contains(tag)) {
      return copyWith(
        tags: [...currentTags, tag],
        lastSavedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// 태그 제거
  Draft removeTag(String tag) {
    final currentTags = tags ?? <String>[];
    if (currentTags.contains(tag)) {
      return copyWith(
        tags: currentTags.where((t) => t != tag).toList(),
        lastSavedAt: DateTime.now(),
      );
    }
    return this;
  }
}

/// 임시저장 통계
class DraftStatistics {
  final int totalCount;
  final int totalSizeBytes;
  final Map<DraftType, int> typeCount;
  final int todayCount;
  final int weekCount;
  final Draft? oldestDraft;
  final Draft? newestDraft;

  DraftStatistics({
    required this.totalCount,
    required this.totalSizeBytes,
    required this.typeCount,
    required this.todayCount,
    required this.weekCount,
    this.oldestDraft,
    this.newestDraft,
  });

  /// 크기를 사람이 읽기 쉬운 형태로 변환
  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '${totalSizeBytes}B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 평균 크기 (바이트)
  double get averageSize {
    return totalCount > 0 ? totalSizeBytes / totalCount : 0;
  }

  /// 가장 많이 사용되는 타입
  DraftType? get mostUsedType {
    if (typeCount.isEmpty) return null;
    
    return typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 타입별 사용률 (퍼센트)
  Map<DraftType, double> get typeUsageRate {
    if (totalCount == 0) return {};
    
    return typeCount.map((type, count) {
      return MapEntry(type, (count / totalCount) * 100);
    });
  }
}

/// 임시저장 필터 옵션
class DraftFilter {
  final DraftType? type;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isAutosaved;
  final List<String>? tags;
  final DraftSortBy sortBy;
  final bool ascending;

  const DraftFilter({
    this.type,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.isAutosaved,
    this.tags,
    this.sortBy = DraftSortBy.lastSaved,
    this.ascending = false,
  });

  /// 필터 적용
  List<Draft> apply(List<Draft> drafts) {
    List<Draft> filtered = List.from(drafts);

    // 타입 필터
    if (type != null) {
      filtered = filtered.where((draft) => draft.type == type).toList();
    }

    // 검색어 필터
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((draft) {
        return draft.title.toLowerCase().contains(query) ||
               draft.content.toLowerCase().contains(query) ||
               (draft.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false);
      }).toList();
    }

    // 날짜 범위 필터
    if (startDate != null) {
      filtered = filtered.where((draft) => 
          draft.createdAt.isAfter(startDate!) || 
          draft.createdAt.isAtSameMomentAs(startDate!)
      ).toList();
    }
    
    if (endDate != null) {
      final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
      filtered = filtered.where((draft) => 
          draft.createdAt.isBefore(endOfDay) || 
          draft.createdAt.isAtSameMomentAs(endOfDay)
      ).toList();
    }

    // 자동저장 여부 필터
    if (isAutosaved != null) {
      filtered = filtered.where((draft) => draft.isAutosaved == isAutosaved).toList();
    }

    // 태그 필터
    if (tags != null && tags!.isNotEmpty) {
      filtered = filtered.where((draft) {
        return draft.tags != null && 
               tags!.every((tag) => draft.tags!.contains(tag));
      }).toList();
    }

    // 정렬
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case DraftSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case DraftSortBy.created:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case DraftSortBy.lastSaved:
          comparison = a.lastSavedAt.compareTo(b.lastSavedAt);
          break;
        case DraftSortBy.type:
          comparison = a.type.name.compareTo(b.type.name);
          break;
      }
      
      return ascending ? comparison : -comparison;
    });

    return filtered;
  }

  /// 복사본 생성
  DraftFilter copyWith({
    DraftType? type,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAutosaved,
    List<String>? tags,
    DraftSortBy? sortBy,
    bool? ascending,
  }) {
    return DraftFilter(
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAutosaved: isAutosaved ?? this.isAutosaved,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// 임시저장 정렬 기준
enum DraftSortBy {
  title,      // 제목
  created,    // 생성일
  lastSaved,  // 최근 저장일
  type,       // 타입
}
