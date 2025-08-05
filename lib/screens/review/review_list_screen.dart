import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/review/star_rating.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({Key? key}) : super(key: key);

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<ReviewProvider>(context, listen: false)
            .refreshAllReviews(authProvider.user!.id, authProvider.user!.type);
      }
    });
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
        title: const Text('리뷰 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '통계'),
            Tab(text: '작성한 리뷰'),
            Tab(text: '받은 리뷰'),
            Tab(text: '작성 대기'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshReviews(),
          ),
        ],
      ),
      body: Consumer2<ReviewProvider, AuthProvider>(
        builder: (context, reviewProvider, authProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildStatsTab(reviewProvider, authProvider),
              _buildMyReviewsTab(reviewProvider),
              _buildReceivedReviewsTab(reviewProvider),
              _buildPendingReviewsTab(reviewProvider, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(ReviewProvider reviewProvider, AuthProvider authProvider) {
    if (reviewProvider.isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewProvider.statsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(reviewProvider.statsError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshReviews(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final stats = reviewProvider.reviewStats;
    if (stats == null) {
      return const Center(
        child: Text('통계 데이터가 없습니다'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 요약
          RatingSummary(
            averageRating: stats.averageScore,
            reviewCount: stats.totalCount,
            scoreDistribution: stats.scoreDistribution,
            showDistribution: true,
          ),

          const SizedBox(height: 24),

          // 추천 통계
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추천 통계',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        title: '추천 받음',
                        value: '${stats.recommendationCount}개',
                        subtitle: '전체 ${stats.totalCount}개 중',
                      ),
                      _buildStatItem(
                        title: '추천률',
                        value: '${(stats.recommendationRate * 100).toStringAsFixed(1)}%',
                        subtitle: '평균보다 높음',
                        color: stats.recommendationRate >= 0.8 ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 카테고리별 평균
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 평점',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...stats.categoryAverages.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(entry.key),
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getCategoryDisplayName(entry.key),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          StarRating(
                            rating: entry.value,
                            isReadOnly: true,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyReviewsTab(ReviewProvider reviewProvider) {
    if (reviewProvider.isLoadingMyReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    final reviews = reviewProvider.myReviews ?? [];
    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '작성한 리뷰가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshReviews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _buildReviewCard(review, isMyReview: true);
        },
      ),
    );
  }

  Widget _buildReceivedReviewsTab(ReviewProvider reviewProvider) {
    if (reviewProvider.isLoadingReceivedReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    final reviews = reviewProvider.receivedReviews ?? [];
    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.reviews, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '받은 리뷰가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshReviews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _buildReviewCard(review, isMyReview: false);
        },
      ),
    );
  }

  Widget _buildPendingReviewsTab(ReviewProvider reviewProvider, AuthProvider authProvider) {
    if (reviewProvider.isLoadingPendingContracts) {
      return const Center(child: CircularProgressIndicator());
    }

    final contracts = reviewProvider.pendingReviewContracts ?? [];
    if (contracts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '리뷰 작성 대기 중인 계약이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshReviews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return _buildPendingReviewCard(contract);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review, {required bool isMyReview}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.campaignName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMyReview 
                            ? '${review.revieweeName}님에게'
                            : '${review.reviewerName}님으로부터',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        StarRating(
                          rating: review.overallScore,
                          isReadOnly: true,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          review.overallScore.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (review.isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Text(
                          '추천',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 리뷰 내용
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // 하단 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateFormat.format(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    if (!isMyReview && review.reply == null)
                      TextButton.icon(
                        onPressed: () => _showReplyDialog(review),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('답글'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    if (isMyReview)
                      TextButton.icon(
                        onPressed: () => _editReview(review),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('수정'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _viewReviewDetail(review),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('자세히'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 답글 표시
            if (review.reply != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.reply, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '답글',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (review.repliedAt != null)
                          Text(
                            _dateFormat.format(review.repliedAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.reply!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReviewCard(Map<String, dynamic> contract) {
    final canReviewUntil = DateTime.parse(contract['can_review_until']);
    final daysLeft = canReviewUntil.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract['campaign_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contract['partner_name']}님과의 협업',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysLeft > 3 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: daysLeft > 3 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$daysLeft일 남음',
                    style: TextStyle(
                      color: daysLeft > 3 ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '완료일: ${_dateFormat.format(DateTime.parse(contract['completed_at']))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _writeReview(contract),
                  icon: const Icon(Icons.rate_review, size: 16),
                  label: const Text('리뷰 작성'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String subtitle,
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(ReviewCategory category) {
    switch (category) {
      case ReviewCategory.communication:
        return Icons.chat;
      case ReviewCategory.quality:
        return Icons.star;
      case ReviewCategory.professionalism:
        return Icons.business;
      case ReviewCategory.punctuality:
        return Icons.schedule;
      case ReviewCategory.creativity:
        return Icons.brush;
      case ReviewCategory.responsiveness:
        return Icons.speed;
    }
  }

  String _getCategoryDisplayName(ReviewCategory category) {
    switch (category) {
      case ReviewCategory.communication:
        return '소통';
      case ReviewCategory.quality:
        return '작업 품질';
      case ReviewCategory.professionalism:
        return '전문성';
      case ReviewCategory.punctuality:
        return '시간 준수';
      case ReviewCategory.creativity:
        return '창의성';
      case ReviewCategory.responsiveness:
        return '반응성';
    }
  }

  Future<void> _refreshReviews() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await Provider.of<ReviewProvider>(context, listen: false)
          .refreshAllReviews(authProvider.user!.id, authProvider.user!.type);
    }
  }

  void _writeReview(Map<String, dynamic> contract) {
    context.push(
      '/review/write?'
      'contractId=${contract['contract_id']}&'
      'campaignName=${Uri.encodeComponent(contract['campaign_name'])}&'
      'partnerId=${contract['partner_id']}&'
      'partnerName=${Uri.encodeComponent(contract['partner_name'])}&'
      'reviewType=${(contract['review_type'] as ReviewType).name}',
    );
  }

  void _editReview(Review review) {
    context.push(
      '/review/write?'
      'contractId=${review.contractId}&'
      'campaignName=${Uri.encodeComponent(review.campaignName)}&'
      'partnerId=${review.revieweeId}&'
      'partnerName=${Uri.encodeComponent(review.revieweeName)}&'
      'reviewType=${review.type.name}&'
      'existingReviewId=${review.id}',
    );
  }

  void _viewReviewDetail(Review review) {
    context.push('/review/${review.id}');
  }

  void _showReplyDialog(Review review) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답글 작성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${review.reviewerName}님의 리뷰에 답글을 작성하세요',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: '감사한 마음을 전하거나 추가 설명을 작성해주세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          Consumer<ReviewProvider>(
            builder: (context, reviewProvider, child) {
              return ElevatedButton(
                onPressed: reviewProvider.isReplyingToReview
                    ? null
                    : () => _submitReply(review.id, replyController.text),
                child: reviewProvider.isReplyingToReview
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('답글 작성'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitReply(String reviewId, String reply) async {
    if (reply.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답글 내용을 입력해주세요')),
      );
      return;
    }

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final updatedReview = await reviewProvider.replyToReview(
      reviewId: reviewId,
      reply: reply.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      if (updatedReview != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답글이 작성되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답글 작성에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
