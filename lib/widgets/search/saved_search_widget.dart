import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/search_filter_model.dart';

class SavedSearchWidget extends StatelessWidget {
  final SavedSearch savedSearch;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SavedSearchWidget({
    Key? key,
    required this.savedSearch,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    savedSearch.icon,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      savedSearch.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                savedSearch.description ?? '저장된 검색 조건',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 검색 조건 요약
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _buildFilterSummaryChips(context),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM/dd HH:mm').format(savedSearch.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (savedSearch.lastUsedAt != null) ...[
                    Text(
                      '마지막 사용: ${_formatLastUsed(savedSearch.lastUsedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilterSummaryChips(BuildContext context) {
    final chips = <Widget>[];
    final filter = savedSearch.searchFilter;
    
    // 타겟 타입
    chips.add(_buildSummaryChip(
      context,
      _getTargetTypeLabel(filter.targetType),
      Icons.category,
    ));
    
    // 키워드
    if (filter.keyword?.isNotEmpty == true) {
      chips.add(_buildSummaryChip(
        context,
        '"${filter.keyword}"',
        Icons.search,
      ));
    }
    
    // 카테고리 수
    if (filter.categories.isNotEmpty) {
      chips.add(_buildSummaryChip(
        context,
        '카테고리 ${filter.categories.length}개',
        Icons.label,
      ));
    }
    
    // 지역 수
    if (filter.regions.isNotEmpty) {
      chips.add(_buildSummaryChip(
        context,
        '지역 ${filter.regions.length}개',
        Icons.location_on,
      ));
    }
    
    // 가격 범위
    if (filter.priceRange != null && !filter.priceRange!.isEmpty) {
      chips.add(_buildSummaryChip(
        context,
        filter.priceRange.toString(),
        Icons.attach_money,
      ));
    }
    
    // 팔로워 범위
    if (filter.followerRange != null && !filter.followerRange!.isEmpty) {
      chips.add(_buildSummaryChip(
        context,
        filter.followerRange.toString(),
        Icons.people,
      ));
    }
    
    // 정렬 방식
    chips.add(_buildSummaryChip(
      context,
      filter.sortDisplayName,
      Icons.sort,
    ));
    
    return chips;
  }

  Widget _buildSummaryChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getTargetTypeLabel(SearchTargetType targetType) {
    switch (targetType) {
      case SearchTargetType.campaign:
        return '캠페인';
      case SearchTargetType.influencer:
        return '인플루언서';
      case SearchTargetType.seller:
        return '판매사';
      case SearchTargetType.contract:
        return '계약';
      case SearchTargetType.review:
        return '리뷰';
    }
  }

  String _formatLastUsed(DateTime lastUsed) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd').format(lastUsed);
    }
  }
}

class SavedSearchListWidget extends StatelessWidget {
  final List<SavedSearch> savedSearches;
  final Function(SavedSearch) onSearchSelected;
  final Function(SavedSearch) onSearchDeleted;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const SavedSearchListWidget({
    Key? key,
    required this.savedSearches,
    required this.onSearchSelected,
    required this.onSearchDeleted,
    this.isLoading = false,
    this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('저장된 검색 불러오는 중...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error!),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
          ],
        ),
      );
    }

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
          onTap: () => onSearchSelected(savedSearch),
          onDelete: () => onSearchDeleted(savedSearch),
        );
      },
    );
  }
}

class SaveSearchDialogWidget extends StatefulWidget {
  final SearchFilter searchFilter;
  final Function(String) onSave;

  const SaveSearchDialogWidget({
    Key? key,
    required this.searchFilter,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SaveSearchDialogWidget> createState() => _SaveSearchDialogWidgetState();
}

class _SaveSearchDialogWidgetState extends State<SaveSearchDialogWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('검색 조건 저장'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '저장 이름',
              hintText: '예: 뷰티 브랜드 캠페인',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '설명 (선택사항)',
              hintText: '검색 조건에 대한 설명',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () {
                  widget.onSave(_nameController.text.trim());
                  Navigator.of(context).pop();
                },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
