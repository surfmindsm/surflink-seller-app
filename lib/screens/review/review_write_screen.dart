import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/review/star_rating.dart';

class ReviewWriteScreen extends StatefulWidget {
  final String contractId;
  final String campaignName;
  final String partnerId;
  final String partnerName;
  final ReviewType reviewType;
  final String? existingReviewId; // 수정의 경우

  const ReviewWriteScreen({
    Key? key,
    required this.contractId,
    required this.campaignName,
    required this.partnerId,
    required this.partnerName,
    required this.reviewType,
    this.existingReviewId,
  }) : super(key: key);

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  double _overallRating = 0.0;
  bool _isRecommended = false;
  
  // 카테고리별 점수
  final Map<ReviewCategory, double> _categoryRatings = {
    ReviewCategory.communication: 0.0,
    ReviewCategory.quality: 0.0,
    ReviewCategory.professionalism: 0.0,
    ReviewCategory.punctuality: 0.0,
    ReviewCategory.creativity: 0.0,
    ReviewCategory.responsiveness: 0.0,
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReviewId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '리뷰 수정' : '리뷰 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<ReviewProvider, AuthProvider>(
        builder: (context, reviewProvider, authProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 협업 정보
                  _buildContractInfoCard(),

                  const SizedBox(height: 24),

                  // 전체 만족도
                  _buildOverallRatingCard(),

                  const SizedBox(height: 24),

                  // 세부 평가
                  _buildDetailRatingCard(),

                  const SizedBox(height: 24),

                  // 리뷰 내용
                  _buildReviewCommentCard(),

                  const SizedBox(height: 24),

                  // 추천 여부
                  _buildRecommendationCard(),

                  const SizedBox(height: 32),

                  // 제출 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSubmit() && !reviewProvider.isSubmittingReview
                          ? () => _submitReview(reviewProvider, authProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: reviewProvider.isSubmittingReview
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? '리뷰 수정하기' : '리뷰 제출하기',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  if (reviewProvider.reviewSubmissionError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reviewProvider.reviewSubmissionError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '협업 정보',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('캠페인명', widget.campaignName),
            const SizedBox(height: 8),
            _buildInfoRow(
              widget.reviewType == ReviewType.sellerToInfluencer ? '인플루언서' : '판매사',
              widget.partnerName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('리뷰 유형', widget.reviewType.name == 'sellerToInfluencer' ? '판매사 → 인플루언서' : '인플루언서 → 판매사'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRatingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 만족도',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  StarRating(
                    rating: _overallRating,
                    size: 40,
                    onRatingChanged: (rating) {
                      setState(() {
                        _overallRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(_overallRating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _getRatingColor(_overallRating),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRatingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '세부 평가',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ReviewCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CategoryRatingInput(
                  title: _getCategoryTitle(category),
                  subtitle: _getCategorySubtitle(category),
                  icon: _getCategoryIcon(category),
                  initialRating: _categoryRatings[category]!,
                  onRatingChanged: (rating) {
                    setState(() {
                      _categoryRatings[category] = rating;
                      _updateOverallRating();
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCommentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 리뷰',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '협업에 대한 상세한 후기를 작성해주세요.\n좋았던 점, 아쉬웠던 점 등을 구체적으로 적어주시면 다른 사용자들에게 도움이 됩니다.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '리뷰 내용을 작성해주세요';
                }
                if (value.trim().length < 10) {
                  return '최소 10자 이상 작성해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추천 의사',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(
                widget.reviewType == ReviewType.sellerToInfluencer
                    ? '이 인플루언서를 다른 판매사에게 추천하시겠습니까?'
                    : '이 판매사를 다른 인플루언서에게 추천하시겠습니까?',
              ),
              subtitle: const Text('추천 의사를 표시하면 상대방의 신뢰도가 높아집니다'),
              value: _isRecommended,
              onChanged: (value) {
                setState(() {
                  _isRecommended = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getCategoryTitle(ReviewCategory category) {
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

  String _getCategorySubtitle(ReviewCategory category) {
    switch (category) {
      case ReviewCategory.communication:
        return '의사소통이 원활했나요?';
      case ReviewCategory.quality:
        return '결과물의 품질은 어땠나요?';
      case ReviewCategory.professionalism:
        return '전문적으로 업무를 처리했나요?';
      case ReviewCategory.punctuality:
        return '약속한 일정을 잘 지켰나요?';
      case ReviewCategory.creativity:
        return '창의적인 아이디어를 제시했나요?';
      case ReviewCategory.responsiveness:
        return '요청사항에 빠르게 반응했나요?';
    }
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

  void _updateOverallRating() {
    final totalScore = _categoryRatings.values.fold(0.0, (sum, score) => sum + score);
    final nonZeroCount = _categoryRatings.values.where((score) => score > 0).length;
    
    if (nonZeroCount > 0) {
      setState(() {
        _overallRating = totalScore / nonZeroCount;
      });
    }
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return '매우 만족';
    if (rating >= 3.5) return '만족';
    if (rating >= 2.5) return '보통';
    if (rating >= 1.5) return '불만족';
    if (rating >= 0.5) return '매우 불만족';
    return '평가 안함';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 1.0) return Colors.red;
    return Colors.grey;
  }

  bool _canSubmit() {
    return _overallRating > 0 && 
           _commentController.text.trim().length >= 10 &&
           _categoryRatings.values.any((score) => score > 0);
  }

  Future<void> _submitReview(ReviewProvider reviewProvider, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final detailScores = _categoryRatings.entries
        .where((entry) => entry.value > 0)
        .map((entry) => ReviewScore(
              category: entry.key,
              score: entry.value,
            ))
        .toList();

    if (widget.existingReviewId != null) {
      // 리뷰 수정
      final updatedReview = await reviewProvider.updateReview(
        reviewId: widget.existingReviewId!,
        overallScore: _overallRating,
        detailScores: detailScores,
        comment: _commentController.text.trim(),
        isRecommended: _isRecommended,
      );

      if (updatedReview != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 수정되었습니다')),
        );
        context.pop();
      }
    } else {
      // 새 리뷰 작성
      final review = await reviewProvider.createReview(
        contractId: widget.contractId,
        reviewerId: authProvider.user!.id,
        revieweeId: widget.partnerId,
        reviewerName: authProvider.user!.name,
        revieweeName: widget.partnerName,
        campaignName: widget.campaignName,
        type: widget.reviewType,
        overallScore: _overallRating,
        detailScores: detailScores,
        comment: _commentController.text.trim(),
        isRecommended: _isRecommended,
      );

      if (review != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다')),
        );
        context.pop();
      }
    }
  }
}
