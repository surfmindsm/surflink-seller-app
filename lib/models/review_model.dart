import 'package:flutter/material.dart';

// 리뷰 타입
enum ReviewType {
  sellerToInfluencer, // 판매사가 인플루언서 평가
  influencerToSeller, // 인플루언서가 판매사 평가
}

// 평가 카테고리
enum ReviewCategory {
  communication, // 소통
  quality, // 작업 품질
  professionalism, // 전문성
  punctuality, // 시간 준수
  creativity, // 창의성
  responsiveness, // 반응성
}

// 리뷰 상태
enum ReviewStatus {
  pending, // 작성 대기
  submitted, // 제출됨
  published, // 공개됨
  hidden, // 숨김
}

// 리뷰 상세 점수
class ReviewScore {
  final ReviewCategory category;
  final double score; // 1.0 ~ 5.0

  ReviewScore({
    required this.category,
    required this.score,
  });

  String get categoryDisplayName {
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

  IconData get categoryIcon {
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

  factory ReviewScore.fromJson(Map<String, dynamic> json) => ReviewScore(
        category: ReviewCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => ReviewCategory.communication,
        ),
        score: json['score'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'score': score,
      };
}

// 리뷰
class Review {
  final String id;
  final String contractId;
  final String reviewerId; // 리뷰 작성자 ID
  final String revieweeId; // 리뷰 대상 ID
  final String reviewerName;
  final String revieweeName;
  final String campaignName;
  final ReviewType type;
  final double overallScore; // 전체 평점 (1.0 ~ 5.0)
  final List<ReviewScore> detailScores; // 세부 평점
  final String comment;
  final List<String>? images; // 첨부 이미지
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final bool isRecommended; // 추천 여부
  final String? reply; // 답글
  final DateTime? repliedAt;

  Review({
    required this.id,
    required this.contractId,
    required this.reviewerId,
    required this.revieweeId,
    required this.reviewerName,
    required this.revieweeName,
    required this.campaignName,
    required this.type,
    required this.overallScore,
    required this.detailScores,
    required this.comment,
    this.images,
    required this.status,
    required this.createdAt,
    this.publishedAt,
    required this.isRecommended,
    this.reply,
    this.repliedAt,
  });

  String get typeDisplayName {
    switch (type) {
      case ReviewType.sellerToInfluencer:
        return '판매사 → 인플루언서';
      case ReviewType.influencerToSeller:
        return '인플루언서 → 판매사';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ReviewStatus.pending:
        return '작성 대기';
      case ReviewStatus.submitted:
        return '제출됨';
      case ReviewStatus.published:
        return '공개됨';
      case ReviewStatus.hidden:
        return '숨김';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.submitted:
        return Colors.blue;
      case ReviewStatus.published:
        return Colors.green;
      case ReviewStatus.hidden:
        return Colors.grey;
    }
  }

  String get scoreText {
    if (overallScore >= 4.5) return '매우 만족';
    if (overallScore >= 3.5) return '만족';
    if (overallScore >= 2.5) return '보통';
    if (overallScore >= 1.5) return '불만족';
    return '매우 불만족';
  }

  Color get scoreColor {
    if (overallScore >= 4.0) return Colors.green;
    if (overallScore >= 3.0) return Colors.orange;
    return Colors.red;
  }

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        contractId: json['contract_id'],
        reviewerId: json['reviewer_id'],
        revieweeId: json['reviewee_id'],
        reviewerName: json['reviewer_name'],
        revieweeName: json['reviewee_name'],
        campaignName: json['campaign_name'],
        type: ReviewType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ReviewType.sellerToInfluencer,
        ),
        overallScore: json['overall_score'].toDouble(),
        detailScores: (json['detail_scores'] as List)
            .map((score) => ReviewScore.fromJson(score))
            .toList(),
        comment: json['comment'],
        images: json['images'] != null 
            ? List<String>.from(json['images'])
            : null,
        status: ReviewStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ReviewStatus.pending,
        ),
        createdAt: DateTime.parse(json['created_at']),
        publishedAt: json['published_at'] != null
            ? DateTime.parse(json['published_at'])
            : null,
        isRecommended: json['is_recommended'] ?? false,
        reply: json['reply'],
        repliedAt: json['replied_at'] != null
            ? DateTime.parse(json['replied_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_id': contractId,
        'reviewer_id': reviewerId,
        'reviewee_id': revieweeId,
        'reviewer_name': reviewerName,
        'reviewee_name': revieweeName,
        'campaign_name': campaignName,
        'type': type.name,
        'overall_score': overallScore,
        'detail_scores': detailScores.map((score) => score.toJson()).toList(),
        'comment': comment,
        'images': images,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'published_at': publishedAt?.toIso8601String(),
        'is_recommended': isRecommended,
        'reply': reply,
        'replied_at': repliedAt?.toIso8601String(),
      };

  Review copyWith({
    String? id,
    String? contractId,
    String? reviewerId,
    String? revieweeId,
    String? reviewerName,
    String? revieweeName,
    String? campaignName,
    ReviewType? type,
    double? overallScore,
    List<ReviewScore>? detailScores,
    String? comment,
    List<String>? images,
    ReviewStatus? status,
    DateTime? createdAt,
    DateTime? publishedAt,
    bool? isRecommended,
    String? reply,
    DateTime? repliedAt,
  }) {
    return Review(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      reviewerName: reviewerName ?? this.reviewerName,
      revieweeName: revieweeName ?? this.revieweeName,
      campaignName: campaignName ?? this.campaignName,
      type: type ?? this.type,
      overallScore: overallScore ?? this.overallScore,
      detailScores: detailScores ?? this.detailScores,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      isRecommended: isRecommended ?? this.isRecommended,
      reply: reply ?? this.reply,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }
}

// 리뷰 통계
class ReviewStats {
  final int totalCount;
  final double averageScore;
  final Map<int, int> scoreDistribution; // 점수별 분포 (1점: n개, 2점: n개, ...)
  final Map<ReviewCategory, double> categoryAverages; // 카테고리별 평균
  final int recommendationCount;
  final double recommendationRate;

  ReviewStats({
    required this.totalCount,
    required this.averageScore,
    required this.scoreDistribution,
    required this.categoryAverages,
    required this.recommendationCount,
    required this.recommendationRate,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) => ReviewStats(
        totalCount: json['total_count'],
        averageScore: json['average_score'].toDouble(),
        scoreDistribution: Map<int, int>.from(json['score_distribution']),
        categoryAverages: (json['category_averages'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(
                  ReviewCategory.values.firstWhere((e) => e.name == key),
                  value.toDouble(),
                )),
        recommendationCount: json['recommendation_count'],
        recommendationRate: json['recommendation_rate'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_count': totalCount,
        'average_score': averageScore,
        'score_distribution': scoreDistribution,
        'category_averages': categoryAverages
            .map((key, value) => MapEntry(key.name, value)),
        'recommendation_count': recommendationCount,
        'recommendation_rate': recommendationRate,
      };
}
