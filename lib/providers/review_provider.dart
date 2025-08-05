import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // 내가 작성한 리뷰들
  List<Review>? _myReviews;
  bool _isLoadingMyReviews = false;
  String? _myReviewsError;

  // 받은 리뷰들
  List<Review>? _receivedReviews;
  bool _isLoadingReceivedReviews = false;
  String? _receivedReviewsError;

  // 리뷰 작성 대기 계약들
  List<Map<String, dynamic>>? _pendingReviewContracts;
  bool _isLoadingPendingContracts = false;
  String? _pendingContractsError;

  // 리뷰 통계
  ReviewStats? _reviewStats;
  bool _isLoadingStats = false;
  String? _statsError;

  // 리뷰 작성/수정
  bool _isSubmittingReview = false;
  String? _reviewSubmissionError;

  // 답글 작성
  bool _isReplyingToReview = false;
  String? _replyError;

  // Getters
  List<Review>? get myReviews => _myReviews;
  bool get isLoadingMyReviews => _isLoadingMyReviews;
  String? get myReviewsError => _myReviewsError;

  List<Review>? get receivedReviews => _receivedReviews;
  bool get isLoadingReceivedReviews => _isLoadingReceivedReviews;
  String? get receivedReviewsError => _receivedReviewsError;

  List<Map<String, dynamic>>? get pendingReviewContracts => _pendingReviewContracts;
  bool get isLoadingPendingContracts => _isLoadingPendingContracts;
  String? get pendingContractsError => _pendingContractsError;

  ReviewStats? get reviewStats => _reviewStats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;

  bool get isSubmittingReview => _isSubmittingReview;
  String? get reviewSubmissionError => _reviewSubmissionError;

  bool get isReplyingToReview => _isReplyingToReview;
  String? get replyError => _replyError;

  // 내가 작성한 리뷰 로드
  Future<void> loadMyReviews(String userId) async {
    _isLoadingMyReviews = true;
    _myReviewsError = null;
    notifyListeners();

    try {
      _myReviews = await _reviewService.getMyReviews(userId);
    } catch (e) {
      _myReviewsError = e.toString();
    } finally {
      _isLoadingMyReviews = false;
      notifyListeners();
    }
  }

  // 받은 리뷰 로드
  Future<void> loadReceivedReviews(String userId) async {
    _isLoadingReceivedReviews = true;
    _receivedReviewsError = null;
    notifyListeners();

    try {
      _receivedReviews = await _reviewService.getReceivedReviews(userId);
    } catch (e) {
      _receivedReviewsError = e.toString();
    } finally {
      _isLoadingReceivedReviews = false;
      notifyListeners();
    }
  }

  // 리뷰 작성 대기 계약 로드
  Future<void> loadPendingReviewContracts(String userId) async {
    _isLoadingPendingContracts = true;
    _pendingContractsError = null;
    notifyListeners();

    try {
      _pendingReviewContracts = await _reviewService.getPendingReviewContracts(userId);
    } catch (e) {
      _pendingContractsError = e.toString();
    } finally {
      _isLoadingPendingContracts = false;
      notifyListeners();
    }
  }

  // 리뷰 통계 로드
  Future<void> loadReviewStats(String userId, UserType userType) async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _reviewStats = await _reviewService.getReviewStats(userId, userType);
    } catch (e) {
      _statsError = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // 리뷰 작성
  Future<Review?> createReview({
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
    _isSubmittingReview = true;
    _reviewSubmissionError = null;
    notifyListeners();

    try {
      final review = await _reviewService.createReview(
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
        isRecommended: isRecommended,
      );

      // 리뷰 목록 업데이트
      if (_myReviews != null) {
        _myReviews = [review, ..._myReviews!];
      }

      // 대기 중인 계약에서 제거
      if (_pendingReviewContracts != null) {
        _pendingReviewContracts!.removeWhere((contract) => contract['contract_id'] == contractId);
      }

      return review;
    } catch (e) {
      _reviewSubmissionError = e.toString();
      return null;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  // 리뷰 수정
  Future<Review?> updateReview({
    required String reviewId,
    double? overallScore,
    List<ReviewScore>? detailScores,
    String? comment,
    List<String>? images,
    bool? isRecommended,
  }) async {
    _isSubmittingReview = true;
    _reviewSubmissionError = null;
    notifyListeners();

    try {
      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        overallScore: overallScore,
        detailScores: detailScores,
        comment: comment,
        images: images,
        isRecommended: isRecommended,
      );

      // 리뷰 목록 업데이트
      if (_myReviews != null) {
        final index = _myReviews!.indexWhere((review) => review.id == reviewId);
        if (index != -1) {
          _myReviews![index] = updatedReview;
        }
      }

      return updatedReview;
    } catch (e) {
      _reviewSubmissionError = e.toString();
      return null;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  // 리뷰 답글 작성
  Future<Review?> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    _isReplyingToReview = true;
    _replyError = null;
    notifyListeners();

    try {
      final updatedReview = await _reviewService.replyToReview(
        reviewId: reviewId,
        reply: reply,
      );

      // 받은 리뷰 목록 업데이트
      if (_receivedReviews != null) {
        final index = _receivedReviews!.indexWhere((review) => review.id == reviewId);
        if (index != -1) {
          _receivedReviews![index] = updatedReview;
        }
      }

      return updatedReview;
    } catch (e) {
      _replyError = e.toString();
      return null;
    } finally {
      _isReplyingToReview = false;
      notifyListeners();
    }
  }

  // 리뷰 삭제
  Future<bool> deleteReview(String reviewId) async {
    try {
      final success = await _reviewService.deleteReview(reviewId);
      
      if (success) {
        // 리뷰 목록에서 제거
        _myReviews?.removeWhere((review) => review.id == reviewId);
        _receivedReviews?.removeWhere((review) => review.id == reviewId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // 리뷰 신고
  Future<bool> reportReview({
    required String reviewId,
    required String reporterId,
    required String reason,
  }) async {
    try {
      return await _reviewService.reportReview(
        reviewId: reviewId,
        reporterId: reporterId,
        reason: reason,
      );
    } catch (e) {
      return false;
    }
  }

  // 리뷰 도움이 됨/안됨 평가
  Future<bool> voteReview({
    required String reviewId,
    required String userId,
    required bool isHelpful,
  }) async {
    try {
      return await _reviewService.voteReview(
        reviewId: reviewId,
        userId: userId,
        isHelpful: isHelpful,
      );
    } catch (e) {
      return false;
    }
  }

  // 특정 사용자의 공개 리뷰 조회
  Future<List<Review>> getUserPublicReviews(String userId, {int limit = 10}) async {
    try {
      return await _reviewService.getUserPublicReviews(userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  // 전체 리뷰 목록 새로고침
  Future<void> refreshAllReviews(String userId, UserType userType) async {
    await Future.wait([
      loadMyReviews(userId),
      loadReceivedReviews(userId),
      loadPendingReviewContracts(userId),
      loadReviewStats(userId, userType),
    ]);
  }

  // 평균 점수 계산
  double getAverageScore(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final totalScore = reviews.fold(0.0, (sum, review) => sum + review.overallScore);
    return totalScore / reviews.length;
  }

  // 추천률 계산
  double getRecommendationRate(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final recommendedCount = reviews.where((review) => review.isRecommended).length;
    return recommendedCount / reviews.length;
  }

  // 리뷰 필터링
  List<Review> filterReviews(List<Review> reviews, {
    double? minScore,
    double? maxScore,
    bool? isRecommended,
    ReviewType? type,
  }) {
    return reviews.where((review) {
      if (minScore != null && review.overallScore < minScore) return false;
      if (maxScore != null && review.overallScore > maxScore) return false;
      if (isRecommended != null && review.isRecommended != isRecommended) return false;
      if (type != null && review.type != type) return false;
      return true;
    }).toList();
  }

  // 리뷰 정렬
  List<Review> sortReviews(List<Review> reviews, String sortBy) {
    final sortedReviews = List<Review>.from(reviews);
    
    switch (sortBy) {
      case 'date_desc':
        sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        sortedReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'score_desc':
        sortedReviews.sort((a, b) => b.overallScore.compareTo(a.overallScore));
        break;
      case 'score_asc':
        sortedReviews.sort((a, b) => a.overallScore.compareTo(b.overallScore));
        break;
      default:
        sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return sortedReviews;
  }

  // 데이터 초기화
  void clearData() {
    _myReviews = null;
    _receivedReviews = null;
    _pendingReviewContracts = null;
    _reviewStats = null;
    _myReviewsError = null;
    _receivedReviewsError = null;
    _pendingContractsError = null;
    _statsError = null;
    _reviewSubmissionError = null;
    _replyError = null;
    notifyListeners();
  }
}
