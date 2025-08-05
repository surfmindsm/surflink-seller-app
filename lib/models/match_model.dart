class MatchCriteria {
  final List<String> categories;
  final int? minBudget;
  final int? maxBudget;
  final String? region;
  final int? minFollowers;
  final int? maxFollowers;
  final bool? isVerified;
  final List<String>? availableTime;

  MatchCriteria({
    required this.categories,
    this.minBudget,
    this.maxBudget,
    this.region,
    this.minFollowers,
    this.maxFollowers,
    this.isVerified,
    this.availableTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'region': region,
      'min_followers': minFollowers,
      'max_followers': maxFollowers,
      'is_verified': isVerified,
      'available_time': availableTime,
    };
  }

  factory MatchCriteria.fromJson(Map<String, dynamic> json) {
    return MatchCriteria(
      categories: List<String>.from(json['categories'] ?? []),
      minBudget: json['min_budget'],
      maxBudget: json['max_budget'],
      region: json['region'],
      minFollowers: json['min_followers'],
      maxFollowers: json['max_followers'],
      isVerified: json['is_verified'],
      availableTime: json['available_time'] != null 
        ? List<String>.from(json['available_time']) 
        : null,
    );
  }
}

class MatchResult {
  final String influencerId;
  final String influencerName;
  final String? profileImage;
  final List<String> categories;
  final int followersCount;
  final String? region;
  final double matchScore;
  final String matchReason;
  final bool isVerified;
  final int? priceAmount;

  MatchResult({
    required this.influencerId,
    required this.influencerName,
    this.profileImage,
    required this.categories,
    required this.followersCount,
    this.region,
    required this.matchScore,
    required this.matchReason,
    required this.isVerified,
    this.priceAmount,
  });

  factory MatchResult.fromInfluencer(
    dynamic influencer, 
    double score, 
    String reason
  ) {
    return MatchResult(
      influencerId: influencer.id,
      influencerName: influencer.name,
      profileImage: influencer.profileImage,
      categories: influencer.categories ?? [],
      followersCount: influencer.followersCount ?? 0,
      region: influencer.region,
      matchScore: score,
      matchReason: reason,
      isVerified: influencer.isProfileVerified,
      priceAmount: influencer.priceAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'influencer_id': influencerId,
      'influencer_name': influencerName,
      'profile_image': profileImage,
      'categories': categories,
      'followers_count': followersCount,
      'region': region,
      'match_score': matchScore,
      'match_reason': matchReason,
      'is_verified': isVerified,
      'price_amount': priceAmount,
    };
  }
}

class AutoMatchRequest {
  final String campaignId;
  final MatchCriteria criteria;
  final int maxResults;

  AutoMatchRequest({
    required this.campaignId,
    required this.criteria,
    this.maxResults = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'criteria': criteria.toJson(),
      'max_results': maxResults,
    };
  }
}

class AutoMatchResponse {
  final String campaignId;
  final List<MatchResult> matches;
  final int totalCount;
  final DateTime matchedAt;

  AutoMatchResponse({
    required this.campaignId,
    required this.matches,
    required this.totalCount,
    required this.matchedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'matches': matches.map((m) => m.toJson()).toList(),
      'total_count': totalCount,
      'matched_at': matchedAt.toIso8601String(),
    };
  }
}
