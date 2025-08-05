import '../models/match_model.dart';
import '../models/user_model.dart';

class AutoMatchService {
  static final AutoMatchService _instance = AutoMatchService._internal();
  factory AutoMatchService() => _instance;
  AutoMatchService._internal();

  // 목업 인플루언서 데이터
  final List<User> _mockInfluencers = [
    User(
      id: 'inf_1',
      email: 'beauty_queen@email.com',
      name: '뷰티퀸',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 100)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: true,
      isBusinessVerified: false,
      nickname: '뷰티퀸',
      region: '서울',
      categories: ['뷰티', '패션', '라이프스타일'],
      followersCount: 150000,
      priceAmount: 500000,
      introduction: '뷰티 전문 인플루언서입니다. 화장품 리뷰와 메이크업 튜토리얼을 전문으로 합니다.',
      profileImage: 'https://picsum.photos/200/200?random=1',
    ),
    User(
      id: 'inf_2',
      email: 'food_lover@email.com',
      name: '맛집탐험가',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 80)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: true,
      isBusinessVerified: false,
      nickname: '맛집탐험가',
      region: '경기',
      categories: ['음식', '여행', '라이프스타일'],
      followersCount: 85000,
      priceAmount: 300000,
      introduction: '전국 맛집을 찾아다니며 리뷰하는 푸드 인플루언서입니다.',
      profileImage: 'https://picsum.photos/200/200?random=2',
    ),
    User(
      id: 'inf_3',
      email: 'tech_guru@email.com',
      name: '테크리뷰어',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 60)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: true,
      isBusinessVerified: false,
      nickname: '테크리뷰어',
      region: '서울',
      categories: ['테크', '디지털', 'IT'],
      followersCount: 200000,
      priceAmount: 800000,
      introduction: '최신 IT 제품과 기술 트렌드를 리뷰하는 테크 인플루언서입니다.',
      profileImage: 'https://picsum.photos/200/200?random=3',
    ),
    User(
      id: 'inf_4',
      email: 'fitness_coach@email.com',
      name: '헬스트레이너',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 120)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: true,
      isBusinessVerified: false,
      nickname: '헬스트레이너',
      region: '부산',
      categories: ['헬스', '피트니스', '건강'],
      followersCount: 120000,
      priceAmount: 400000,
      introduction: '건강한 라이프스타일과 운동 루틴을 공유하는 피트니스 인플루언서입니다.',
      profileImage: 'https://picsum.photos/200/200?random=4',
    ),
    User(
      id: 'inf_5',
      email: 'fashion_style@email.com',
      name: '패션스타',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 90)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: false, // 미인증
      isBusinessVerified: false,
      nickname: '패션스타',
      region: '대구',
      categories: ['패션', '뷰티', '쇼핑'],
      followersCount: 95000,
      priceAmount: 350000,
      introduction: '트렌디한 패션 스타일링과 코디를 제안하는 패션 인플루언서입니다.',
      profileImage: 'https://picsum.photos/200/200?random=5',
    ),
    User(
      id: 'inf_6',
      email: 'travel_blogger@email.com',
      name: '여행작가',
      type: UserType.influencer,
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 150)),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      isProfileVerified: true,
      isBusinessVerified: false,
      nickname: '여행작가',
      region: '제주',
      categories: ['여행', '음식', '라이프스타일'],
      followersCount: 180000,
      priceAmount: 600000,
      introduction: '국내외 여행지를 소개하고 여행 정보를 공유하는 여행 인플루언서입니다.',
      profileImage: 'https://picsum.photos/200/200?random=6',
    ),
  ];

  /// 자동매칭 실행
  Future<AutoMatchResponse> performAutoMatch(AutoMatchRequest request) async {
    // 실제 서비스에서는 서버 API 호출
    await Future.delayed(Duration(seconds: 2)); // 로딩 시뮬레이션

    final matches = _calculateMatches(request.criteria);
    
    return AutoMatchResponse(
      campaignId: request.campaignId,
      matches: matches.take(request.maxResults).toList(),
      totalCount: matches.length,
      matchedAt: DateTime.now(),
    );
  }

  /// 매칭 점수 계산 및 결과 생성
  List<MatchResult> _calculateMatches(MatchCriteria criteria) {
    List<MatchResult> results = [];

    for (User influencer in _mockInfluencers) {
      double score = _calculateMatchScore(influencer, criteria);
      String reason = _generateMatchReason(influencer, criteria);

      if (score > 0.3) { // 최소 30% 이상 매칭시에만 결과에 포함
        results.add(MatchResult.fromInfluencer(influencer, score, reason));
      }
    }

    // 점수 높은 순으로 정렬
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return results;
  }

  /// 매칭 점수 계산 알고리즘
  double _calculateMatchScore(User influencer, MatchCriteria criteria) {
    double score = 0.0;
    int factors = 0;

    // 1. 카테고리 매칭 (가중치 40%)
    if (influencer.categories != null && criteria.categories.isNotEmpty) {
      int matchingCategories = influencer.categories!
          .where((cat) => criteria.categories.contains(cat))
          .length;
      double categoryScore = matchingCategories / criteria.categories.length;
      score += categoryScore * 0.4;
      factors++;
    }

    // 2. 팔로워 수 조건 (가중치 25%)
    if (criteria.minFollowers != null || criteria.maxFollowers != null) {
      int followers = influencer.followersCount ?? 0;
      bool followersMatch = true;
      
      if (criteria.minFollowers != null && followers < criteria.minFollowers!) {
        followersMatch = false;
      }
      if (criteria.maxFollowers != null && followers > criteria.maxFollowers!) {
        followersMatch = false;
      }
      
      if (followersMatch) {
        score += 0.25;
      }
      factors++;
    }

    // 3. 지역 매칭 (가중치 15%)
    if (criteria.region != null && influencer.region != null) {
      if (influencer.region == criteria.region) {
        score += 0.15;
      }
      factors++;
    }

    // 4. 인증 여부 (가중치 10%)
    if (criteria.isVerified != null) {
      if (criteria.isVerified == influencer.isProfileVerified) {
        score += 0.10;
      }
      factors++;
    }

    // 5. 예산 대비 가격 (가중치 10%)
    if (criteria.minBudget != null && influencer.priceAmount != null) {
      final maxBudget = criteria.maxBudget ?? criteria.minBudget!;
      if (influencer.priceAmount! <= maxBudget) {
        score += 0.10;
      }
      factors++;
    }

    // 평균 점수 반환
    return factors > 0 ? score : 0.0;
  }

  /// 매칭 이유 생성
  String _generateMatchReason(User influencer, MatchCriteria criteria) {
    List<String> reasons = [];

    // 카테고리 매칭
    if (influencer.categories != null && criteria.categories.isNotEmpty) {
      var matchingCategories = influencer.categories!
          .where((cat) => criteria.categories.contains(cat))
          .toList();
      if (matchingCategories.isNotEmpty) {
        reasons.add('${matchingCategories.join(", ")} 카테고리 전문');
      }
    }

    // 팔로워 수
    if (influencer.followersCount != null) {
      if (influencer.followersCount! >= 100000) {
        reasons.add('높은 영향력 (${_formatFollowers(influencer.followersCount!)})');
      } else {
        reasons.add('적정 영향력 (${_formatFollowers(influencer.followersCount!)})');
      }
    }

    // 지역 매칭
    if (criteria.region != null && influencer.region == criteria.region) {
      reasons.add('${criteria.region} 지역 활동');
    }

    // 인증 여부
    if (influencer.isProfileVerified) {
      reasons.add('프로필 인증 완료');
    }

    return reasons.isEmpty ? '기본 조건 만족' : reasons.join(' • ');
  }

  /// 팔로워 수 포맷팅
  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    } else {
      return followers.toString();
    }
  }

  /// 카테고리 목록 조회
  List<String> getAvailableCategories() {
    return [
      '뷰티',
      '패션',
      '음식',
      '여행',
      '테크',
      '헬스',
      '라이프스타일',
      '육아',
      '인테리어',
      '반려동물',
      '게임',
      '교육',
      '자동차',
      '금융',
      '부동산'
    ];
  }

  /// 지역 목록 조회
  List<String> getAvailableRegions() {
    return [
      '서울',
      '경기',
      '인천',
      '부산',
      '대구',
      '광주',
      '대전',
      '울산',
      '강원',
      '충북',
      '충남',
      '전북',
      '전남',
      '경북',
      '경남',
      '제주'
    ];
  }
}
