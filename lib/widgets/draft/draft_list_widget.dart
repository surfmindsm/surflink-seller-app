import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/draft_model.dart';
import '../../services/draft_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

/// 임시저장 목록 위젯
class DraftListWidget extends StatefulWidget {
  final DraftType? filterType;
  final Function(Draft)? onDraftTap;
  final bool compact;

  const DraftListWidget({
    Key? key,
    this.filterType,
    this.onDraftTap,
    this.compact = false,
  }) : super(key: key);

  @override
  State<DraftListWidget> createState() => _DraftListWidgetState();
}

class _DraftListWidgetState extends State<DraftListWidget> {
  final DraftService _draftService = DraftService();
  List<Draft> _drafts = [];
  bool _isLoading = true;
  DraftFilter _filter = const DraftFilter();

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(
        child: Text('로그인이 필요합니다.'),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredDrafts = _filter.apply(_drafts);

    if (filteredDrafts.isEmpty) {
      return _buildEmptyState();
    }

    if (widget.compact) {
      return _buildCompactList(filteredDrafts);
    }

    return Column(
      children: [
        // 필터 및 검색
        _buildFilterBar(),
        const SizedBox(height: 12),
        
        // 임시저장 목록
        Expanded(
          child: _buildDraftList(filteredDrafts),
        ),
      ],
    );
  }

  /// 임시저장 로드
  Future<void> _loadDrafts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      List<Draft> drafts;
      if (widget.filterType != null) {
        drafts = await _draftService.getDraftsByType(user.id, widget.filterType!);
      } else {
        drafts = await _draftService.getAllDrafts(user.id);
      }

      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('임시저장을 불러오는데 실패했습니다.');
    }
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drafts_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '저장된 임시저장이 없습니다.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '작성 중인 내용을 임시저장하면 여기에 나타납니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 필터 바
  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 검색 바
            TextField(
              decoration: const InputDecoration(
                hintText: '제목이나 내용으로 검색...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (query) {
                setState(() {
                  _filter = _filter.copyWith(searchQuery: query);
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // 필터 옵션
            Row(
              children: [
                // 타입 필터
                if (widget.filterType == null)
                  Expanded(
                    child: DropdownButtonFormField<DraftType?>(
                      value: _filter.type,
                      decoration: const InputDecoration(
                        labelText: '타입',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('전체')),
                        ...DraftType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getDraftTypeName(type)),
                        )),
                      ],
                      onChanged: (type) {
                        setState(() {
                          _filter = _filter.copyWith(type: type);
                        });
                      },
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // 정렬 옵션
                Expanded(
                  child: DropdownButtonFormField<DraftSortBy>(
                    value: _filter.sortBy,
                    decoration: const InputDecoration(
                      labelText: '정렬',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: DraftSortBy.lastSaved, child: Text('최근 저장순')),
                      const DropdownMenuItem(value: DraftSortBy.created, child: Text('생성일순')),
                      const DropdownMenuItem(value: DraftSortBy.title, child: Text('제목순')),
                      const DropdownMenuItem(value: DraftSortBy.type, child: Text('타입순')),
                    ],
                    onChanged: (sortBy) {
                      setState(() {
                        _filter = _filter.copyWith(sortBy: sortBy ?? DraftSortBy.lastSaved);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 임시저장 목록
  Widget _buildDraftList(List<Draft> drafts) {
    return ListView.builder(
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return _buildDraftItem(draft);
      },
    );
  }

  /// 컴팩트 목록
  Widget _buildCompactList(List<Draft> drafts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: drafts.take(5).length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return _buildCompactDraftItem(draft);
      },
    );
  }

  /// 임시저장 아이템
  Widget _buildDraftItem(Draft draft) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: draft.typeColor.withOpacity(0.1),
          child: Icon(
            draft.typeIcon,
            color: draft.typeColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                draft.title.isNotEmpty ? draft.title : '제목 없음',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: draft.title.isEmpty ? Colors.grey : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (draft.isAutosaved)
              Icon(
                Icons.autorenew,
                size: 16,
                color: Colors.green.shade600,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              draft.previewText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.grey600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: draft.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    draft.typeName,
                    style: TextStyle(
                      fontSize: 11,
                      color: draft.typeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    draft.lastSavedText,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleDraftAction(action, draft),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('편집')),
            const PopupMenuItem(value: 'duplicate', child: Text('복제')),
            const PopupMenuItem(value: 'delete', child: Text('삭제')),
          ],
        ),
        onTap: () => _onDraftTap(draft),
      ),
    );
  }

  /// 컴팩트 임시저장 아이템
  Widget _buildCompactDraftItem(Draft draft) {
    return ListTile(
      dense: true,
      leading: Icon(
        draft.typeIcon,
        color: draft.typeColor,
        size: 20,
      ),
      title: Text(
        draft.title.isNotEmpty ? draft.title : '제목 없음',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: draft.title.isEmpty ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        draft.lastSavedText,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.grey500,
        ),
      ),
      trailing: draft.isAutosaved 
          ? Icon(Icons.autorenew, size: 14, color: Colors.green.shade600)
          : null,
      onTap: () => _onDraftTap(draft),
    );
  }

  /// 임시저장 탭 처리
  void _onDraftTap(Draft draft) {
    if (widget.onDraftTap != null) {
      widget.onDraftTap!(draft);
    } else {
      // 기본 동작: 해당 화면으로 이동
      _navigateToDraftEditScreen(draft);
    }
  }

  /// 임시저장 액션 처리
  Future<void> _handleDraftAction(String action, Draft draft) async {
    switch (action) {
      case 'edit':
        _navigateToDraftEditScreen(draft);
        break;
      case 'duplicate':
        await _duplicateDraft(draft);
        break;
      case 'delete':
        await _deleteDraft(draft);
        break;
    }
  }

  /// 임시저장 편집 화면으로 이동
  void _navigateToDraftEditScreen(Draft draft) {
    // TODO: 실제 편집 화면으로 이동
    _showInfoSnackBar('${draft.typeName} 편집 기능은 곧 추가됩니다.');
  }

  /// 임시저장 복제
  Future<void> _duplicateDraft(Draft draft) async {
    try {
      final duplicated = await _draftService.duplicateDraft(draft);
      if (duplicated != null) {
        await _loadDrafts();
        _showSuccessSnackBar('임시저장이 복제되었습니다.');
      } else {
        _showErrorSnackBar('복제에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('복제 중 오류가 발생했습니다.');
    }
  }

  /// 임시저장 삭제
  Future<void> _deleteDraft(Draft draft) async {
    final confirmed = await _showDeleteConfirmDialog(draft);
    if (!confirmed) return;

    try {
      final success = await _draftService.deleteDraft(
        draft.userId,
        draft.type,
        draft.id,
      );
      
      if (success) {
        await _loadDrafts();
        _showSuccessSnackBar('임시저장이 삭제되었습니다.');
      } else {
        _showErrorSnackBar('삭제에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('삭제 중 오류가 발생했습니다.');
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool> _showDeleteConfirmDialog(Draft draft) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('임시저장 삭제'),
        content: Text('${draft.title.isNotEmpty ? draft.title : draft.typeName} 임시저장을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 타입 이름 반환
  String _getDraftTypeName(DraftType type) {
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

  /// 성공 스낵바
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 에러 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 정보 스낵바
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
