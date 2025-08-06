import '../models/review_model.dart';
import '../models/user_model.dart';

class ReviewService {
  // 리뷰 목록 조회 (작성한 리뷰)
  Future<List<Review>> getMyReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    return [
      Review(
        id: 'review_1',
        contractId: 'contract_1',
        reviewerId: userId,
        revieweeId: 'influencer_1',
        reviewerName: '판매사A',
        revieweeName: '뷰티인플루언서',
        campaignName: 'ABC 브랜드 신제품 런칭 캠페인',
        type: ReviewType.sellerToInfluencer,
        overallScore: 4.5,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 4.0),
          ReviewScore(category: ReviewCategory.quality, score: 5.0),
          ReviewScore(category: ReviewCategory.professionalism, score: 4.5),
          ReviewScore(category: ReviewCategory.punctuality, score: 4.0),
          ReviewScore(category: ReviewCategory.creativity, score: 5.0),
        ],
        comment: '정말 전문적이고 창의적인 콘텐츠를 제작해주셨습니다. 소통도 원활했고 품질이 매우 만족스러웠습니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 2)),
        publishedAt: now.subtract(const Duration(days: 2)),
        isRecommended: true,
        reply: '좋은 평가 감사합니다! 앞으로도 더 좋은 콘텐츠로 보답하겠습니다.',
        repliedAt: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'review_2',
        contractId: 'contract_2',
        reviewerId: userId,
        revieweeId: 'influencer_2',
        reviewerName: '판매사B',
        revieweeName: '패션스타일리스트',
        campaignName: 'XYZ 패션 브랜드 협업',
        type: ReviewType.sellerToInfluencer,
        overallScore: 3.8,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 4.0),
          ReviewScore(category: ReviewCategory.quality, score: 4.0),
          ReviewScore(category: ReviewCategory.professionalism, score: 3.5),
          ReviewScore(category: ReviewCategory.punctuality, score: 3.0),
          ReviewScore(category: ReviewCategory.creativity, score: 4.5),
        ],
        comment: '전반적으로 만족스러웠으나 일정 관리 부분에서 아쉬웠습니다. 다음에는 더 원활한 소통을 기대합니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 5)),
        isRecommended: false,
      ),
      Review(
        id: 'review_3',
        contractId: 'contract_3',
        reviewerId: userId,
        revieweeId: 'influencer_3',
        reviewerName: '판매사C',
        revieweeName: '헬스인플루언서',
        campaignName: '건강식품 체험단 모집',
        type: ReviewType.sellerToInfluencer,
        overallScore: 4.2,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 4.0),
          ReviewScore(category: ReviewCategory.quality, score: 4.5),
          ReviewScore(category: ReviewCategory.professionalism, score: 4.0),
          ReviewScore(category: ReviewCategory.punctuality, score: 4.0),
          ReviewScore(category: ReviewCategory.creativity, score: 4.5),
          ReviewScore(category: ReviewCategory.responsiveness, score: 4.0),
        ],
        comment: '전문성이 냐고 쿨리티도 좋았습니다. 소통도 원활했어요.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 8)),
        publishedAt: now.subtract(const Duration(days: 8)),
        isRecommended: true,
        reply: '감사합니다! 앞으로도 더 좋은 콘텐츠로 보답하겠습니다.',
        repliedAt: now.subtract(const Duration(days: 7)),
      ),
      Review(
        id: 'review_4',
        contractId: 'contract_4',
        reviewerId: userId,
        revieweeId: 'influencer_4',
        reviewerName: '판매사D',
        revieweeName: '맛집탐험가',
        campaignName: '카페 체인 매장 홍보',
        type: ReviewType.sellerToInfluencer,
        overallScore: 3.5,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 3.0),
          ReviewScore(category: ReviewCategory.quality, score: 4.0),
          ReviewScore(category: ReviewCategory.professionalism, score: 3.5),
          ReviewScore(category: ReviewCategory.punctuality, score: 3.0),
          ReviewScore(category: ReviewCategory.creativity, score: 4.0),
          ReviewScore(category: ReviewCategory.responsiveness, score: 3.5),
        ],
        comment: '콘텐츠 품질은 좋았지만 소통 반응이 다소 느렸습니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 12)),
        publishedAt: now.subtract(const Duration(days: 12)),
        isRecommended: false,
      ),
      Review(
        id: 'review_5',
        contractId: 'contract_5',
        reviewerId: userId,
        revieweeId: 'influencer_5',
        reviewerName: '판매사E',
        revieweeName: '게임 리뷰어',
        campaignName: '게임 신작 체험단',
        type: ReviewType.sellerToInfluencer,
        overallScore: 4.8,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 5.0),
          ReviewScore(category: ReviewCategory.quality, score: 5.0),
          ReviewScore(category: ReviewCategory.professionalism, score: 4.5),
          ReviewScore(category: ReviewCategory.punctuality, score: 4.5),
          ReviewScore(category: ReviewCategory.creativity, score: 5.0),
          ReviewScore(category: ReviewCategory.responsiveness, score: 5.0),
        ],
        comment: '전문적이고 창의적인 콘텐츠를 제작해주셨습니다. 특히 게임에 대한 이해도가 높아서 매우 만족합니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 1)),
        isRecommended: true,
        reply: '좋은 평가 감사합니다! 다음 프로젝트도 기대해주세요.',
        repliedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  // 받은 리뷰 목록 조회
  Future<List<Review>> getReceivedReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    return [
      Review(
        id: 'review_3',
        contractId: 'contract_3',
        reviewerId: 'seller_1',
        revieweeId: userId,
        reviewerName: 'ABC Company',
        revieweeName: '내 닉네임',
        campaignName: '건강식품 체험단 모집',
        type: ReviewType.sellerToInfluencer,
        overallScore: 4.7,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 5.0),
          ReviewScore(category: ReviewCategory.quality, score: 4.5),
          ReviewScore(category: ReviewCategory.professionalism, score: 4.5),
          ReviewScore(category: ReviewCategory.punctuality, score: 5.0),
          ReviewScore(category: ReviewCategory.creativity, score: 4.5),
        ],
        comment: '매우 성실하고 전문적으로 작업해주셨습니다. 시간 약속도 잘 지켜주시고 결과물의 퀄리티가 높았습니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 3)),
        isRecommended: true,
      ),
      Review(
        id: 'review_4',
        contractId: 'contract_4',
        reviewerId: 'seller_2',
        revieweeId: userId,
        reviewerName: 'Health Brand',
        revieweeName: '내 닉네임',
        campaignName: '홈트레이닝 기구 리뷰',
        type: ReviewType.sellerToInfluencer,
        overallScore: 4.2,
        detailScores: [
          ReviewScore(category: ReviewCategory.communication, score: 4.0),
          ReviewScore(category: ReviewCategory.quality, score: 4.5),
          ReviewScore(category: ReviewCategory.professionalism, score: 4.0),
          ReviewScore(category: ReviewCategory.punctuality, score: 4.0),
          ReviewScore(category: ReviewCategory.creativity, score: 4.5),
        ],
        comment: '좋은 품질의 콘텐츠를 제작해주셨습니다. 앞으로도 함께 작업하고 싶습니다.',
        status: ReviewStatus.published,
        createdAt: now.subtract(const Duration(days: 7)),
        publishedAt: now.subtract(const Duration(days: 7)),
        isRecommended: true,
      ),
    ];
  }

  // 리뷰 작성 가능한 계약 목록
  Future<List<Map<String, dynamic>>> getPendingReviewContracts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    return [
      {
        'contract_id': 'contract_5',
        'campaign_name': '뷰티 브랜드 체험단',
        'partner_id': 'influencer_3',
        'partner_name': '뷰티인플루언서3',
        'review_type': ReviewType.sellerToInfluencer,
        'completed_at': now.subtract(const Duration(days: 1)),
        'can_review_until': now.add(const Duration(days: 6)),
      },
      {
        'contract_id': 'contract_6',
        'campaign_name': '건강기능식품 홍보',
        'partner_id': 'influencer_4',
        'partner_name': '헬스인플루언서',
        'review_type': ReviewType.sellerToInfluencer,
        'completed_at': now.subtract(const Duration(days: 3)),
        'can_review_until': now.add(const Duration(days: 4)),
      },
    ];
  }

  // 리뷰 작성
  Future<Review> createReview({
    required String contractId,
    required String reviewerId,
    required String revieweeId,
    required String reviewerName,
    required String revieweeName,
    required String campaignName,
    required ReviewType type,
    required double overallScore,
    required List<ReviewScore> detailScores,
    required String comment,
    List<String>? images,
    required bool isRecommended,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return Review(
      id: 'review_${now.millisecondsSinceEpoch}',
      contractId: contractId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      reviewerName: reviewerName,
      revieweeName: revieweeName,
      campaignName: campaignName,
      type: type,
      overallScore: overallScore,
      detailScores: detailScores,
      comment: comment,
      images: images,
      status: ReviewStatus.published,
      createdAt: now,
      publishedAt: now,
      isRecommended: isRecommended,
    );
  }

  // 리뷰 수정
  Future<Review> updateReview({
    required String reviewId,
    double? overallScore,
    List<ReviewScore>? detailScores,
    String? comment,
    List<String>? images,
    bool? isRecommended,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock update - 실제로는 기존 리뷰를 가져와서 업데이트
    final now = DateTime.now();
    return Review(
      id: reviewId,
      contractId: 'contract_1',
      reviewerId: 'user_1',
      revieweeId: 'user_2',
      reviewerName: '판매사명',
      revieweeName: '인플루언서명',
      campaignName: '업데이트된 캠페인',
      type: ReviewType.sellerToInfluencer,
      overallScore: overallScore ?? 4.0,
      detailScores: detailScores ?? [],
      comment: comment ?? '업데이트된 리뷰',
      images: images,
      status: ReviewStatus.published,
      createdAt: now.subtract(const Duration(hours: 1)),
      publishedAt: now,
      isRecommended: isRecommended ?? true,
    );
  }

  // 리뷰 답글 작성
  Future<Review> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock reply - 실제로는 기존 리뷰에 답글 추가
    final now = DateTime.now();
    return Review(
      id: reviewId,
      contractId: 'contract_1',
      reviewerId: 'user_1',
      revieweeId: 'user_2',
      reviewerName: '판매사명',
      revieweeName: '인플루언서명',
      campaignName: '캠페인명',
      type: ReviewType.sellerToInfluencer,
      overallScore: 4.0,
      detailScores: [],
      comment: '기존 리뷰 내용',
      status: ReviewStatus.published,
      createdAt: now.subtract(const Duration(hours: 1)),
      publishedAt: now.subtract(const Duration(hours: 1)),
      isRecommended: true,
      reply: reply,
      repliedAt: now,
    );
  }

  // 리뷰 삭제
  Future<bool> deleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true; // Mock success
  }

  // 리뷰 통계 조회
  Future<ReviewStats> getReviewStats(String userId, UserType userType) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (userType == UserType.seller) {
      return ReviewStats(
        totalCount: 15,
        averageScore: 4.3,
        scoreDistribution: {
          1: 0,
          2: 1,
          3: 2,
          4: 7,
          5: 5,
        },
        categoryAverages: {
          ReviewCategory.communication: 4.2,
          ReviewCategory.quality: 4.5,
          ReviewCategory.professionalism: 4.1,
          ReviewCategory.punctuality: 4.0,
          ReviewCategory.creativity: 4.6,
          ReviewCategory.responsiveness: 4.3,
        },
        recommendationCount: 12,
        recommendationRate: 0.8,
      );
    } else {
      return ReviewStats(
        totalCount: 28,
        averageScore: 4.6,
        scoreDistribution: {
          1: 0,
          2: 1,
          3: 3,
          4: 12,
          5: 12,
        },
        categoryAverages: {
          ReviewCategory.communication: 4.7,
          ReviewCategory.quality: 4.8,
          ReviewCategory.professionalism: 4.5,
          ReviewCategory.punctuality: 4.4,
          ReviewCategory.creativity: 4.9,
          ReviewCategory.responsiveness: 4.6,
        },
        recommendationCount: 25,
        recommendationRate: 0.89,
      );
    }
  }

  // 특정 사용자의 공개 리뷰 조회 (프로필용)
  Future<List<Review>> getUserPublicReviews(String userId, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final reviews = await getReceivedReviews(userId);
    return reviews
        .where((review) => review.status == ReviewStatus.published)
        .take(limit)
        .toList();
  }

  // 리뷰 신고
  Future<bool> reportReview({
    required String reviewId,
    required String reporterId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Mock success
  }

  // 리뷰 도움이 됨/안됨 평가
  Future<bool> voteReview({
    required String reviewId,
    required String userId,
    required bool isHelpful,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // Mock success
  }
}
