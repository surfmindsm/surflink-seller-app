import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auto_match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/matching/match_criteria_form.dart';
import '../../widgets/matching/match_result_list.dart';

class AutoMatchScreen extends StatefulWidget {
  final String? campaignId;

  const AutoMatchScreen({
    Key? key,
    this.campaignId,
  }) : super(key: key);

  @override
  State<AutoMatchScreen> createState() => _AutoMatchScreenState();
}

class _AutoMatchScreenState extends State<AutoMatchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자동매칭'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.tune),
              text: '매칭 조건',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: '매칭 결과',
            ),
          ],
        ),
      ),
      body: Consumer<AutoMatchProvider>(
        builder: (context, matchProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // 매칭 조건 설정 탭
              _buildCriteriaTab(matchProvider),
              // 매칭 결과 탭
              _buildResultsTab(matchProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCriteriaTab(AutoMatchProvider matchProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '스마트 매칭',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI가 캠페인 조건에 맞는 최적의 인플루언서를 찾아드립니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 매칭 조건 폼
          MatchCriteriaForm(
            onCriteriaChanged: (criteria) {
              matchProvider.updateCriteria(criteria);
            },
            onMatchRequested: (criteria) async {
              final campaignId = widget.campaignId ?? 'demo_campaign';
              await matchProvider.performAutoMatch(
                campaignId: campaignId,
                criteria: criteria,
              );
              
              // 결과 탭으로 이동
              _tabController.animateTo(1);
            },
          ),

          const SizedBox(height: 16),

          // 현재 설정된 조건 미리보기
          if (matchProvider.currentCriteria != null)
            _buildCriteriaPreview(matchProvider.currentCriteria!),
        ],
      ),
    );
  }

  Widget _buildResultsTab(AutoMatchProvider matchProvider) {
    if (matchProvider.isLoading) {
      return const Center(
        child: LoadingWidget(message: '매칭 중...'),
      );
    }

    if (matchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              '매칭 중 오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              matchProvider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                matchProvider.clearError();
                _tabController.animateTo(0);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (matchProvider.lastMatchResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '매칭 조건을 설정하고\n자동매칭을 시작해보세요',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('매칭 조건 설정'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 매칭 결과 헤더
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '매칭 완료',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${matchProvider.matches.length}명의 인플루언서를 찾았습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(0),
                child: const Text('조건 수정'),
              ),
            ],
          ),
        ),

        // 매칭 결과 리스트
        Expanded(
          child: MatchResultList(
            matches: matchProvider.matches,
            onInfluencerTap: (matchResult) {
              _showInfluencerDetail(matchResult);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaPreview(MatchCriteria criteria) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설정된 매칭 조건',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (criteria.categories.isNotEmpty) ...[
              _buildCriteriaItem(
                icon: Icons.category,
                label: '카테고리',
                value: criteria.categories.join(', '),
              ),
              const SizedBox(height: 8),
            ],
            
            if (criteria.minBudget != null || criteria.maxBudget != null) ...[
              _buildCriteriaItem(
                icon: Icons.attach_money,
                label: '예산',
                value: _formatBudgetRange(criteria.minBudget, criteria.maxBudget),
              ),
              const SizedBox(height: 8),
            ],
            
            if (criteria.region != null) ...[
              _buildCriteriaItem(
                icon: Icons.location_on,
                label: '지역',
                value: criteria.region!,
              ),
              const SizedBox(height: 8),
            ],
            
            if (criteria.minFollowers != null || criteria.maxFollowers != null) ...[
              _buildCriteriaItem(
                icon: Icons.people,
                label: '팔로워',
                value: _formatFollowerRange(criteria.minFollowers, criteria.maxFollowers),
              ),
              const SizedBox(height: 8),
            ],
            
            if (criteria.isVerified != null) ...[
              _buildCriteriaItem(
                icon: Icons.verified,
                label: '인증',
                value: criteria.isVerified! ? '인증 계정만' : '전체',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatBudgetRange(int? min, int? max) {
    if (min != null && max != null) {
      return '${_formatMoney(min)} ~ ${_formatMoney(max)}';
    } else if (min != null) {
      return '${_formatMoney(min)} 이상';
    } else if (max != null) {
      return '${_formatMoney(max)} 이하';
    }
    return '제한 없음';
  }

  String _formatFollowerRange(int? min, int? max) {
    if (min != null && max != null) {
      return '${_formatNumber(min)} ~ ${_formatNumber(max)}';
    } else if (min != null) {
      return '${_formatNumber(min)} 이상';
    } else if (max != null) {
      return '${_formatNumber(max)} 이하';
    }
    return '제한 없음';
  }

  String _formatMoney(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}백만원';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}만원';
    } else {
      return '${amount}원';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  void _showInfluencerDetail(MatchResult matchResult) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 핸들
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 인플루언서 상세 정보
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 프로필 헤더
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                matchResult.profileImage ?? 
                                'https://picsum.photos/200/200?random=${matchResult.influencerId.hashCode}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        matchResult.influencerName,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (matchResult.isVerified) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '팔로워 ${_formatNumber(matchResult.followersCount)}명',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (matchResult.region != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      matchResult.region!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 매칭 점수
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Provider.of<AutoMatchProvider>(context, listen: false)
                                .getScoreColor(matchResult.matchScore)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Provider.of<AutoMatchProvider>(context, listen: false)
                                  .getScoreColor(matchResult.matchScore),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: Provider.of<AutoMatchProvider>(context, listen: false)
                                    .getScoreColor(matchResult.matchScore),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '매칭 점수: ${(matchResult.matchScore * 100).toInt()}%',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Provider.of<AutoMatchProvider>(context, listen: false)
                                            .getScoreColor(matchResult.matchScore),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      matchResult.matchReason,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 카테고리
                        if (matchResult.categories.isNotEmpty) ...[
                          Text(
                            '전문 분야',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: matchResult.categories.map((category) {
                              return Chip(
                                label: Text(category),
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // 가격 정보
                        if (matchResult.priceAmount != null) ...[
                          Text(
                            '협업 비용',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              '${_formatMoney(matchResult.priceAmount!)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        
                        // 액션 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: 채팅하기 기능 구현
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('채팅 기능은 곧 구현됩니다')),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text('채팅하기'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: 제안하기 기능 구현
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('제안하기 기능은 곧 구현됩니다')),
                                  );
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('제안하기'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
