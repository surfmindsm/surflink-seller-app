import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class InfluencerCard extends StatelessWidget {
  final User influencer;
  final VoidCallback? onTap;

  const InfluencerCard({
    Key? key,
    required this.influencer,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 정보
              Row(
                children: [
                  // 프로필 이미지 (임시)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      influencer.name.isNotEmpty ? influencer.name[0] : '?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 이름 및 닉네임
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          influencer.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (influencer.nickname != null && influencer.nickname!.isNotEmpty)
                          Text(
                            '@${influencer.nickname}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 인증 배지
                  if (influencer.isProfileVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 팔로워수
              if (influencer.followersCount != null)
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '팔로워 ${_formatFollowers(influencer.followersCount!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // 지역
              if (influencer.region != null && influencer.region!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      influencer.region!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // 카테고리
              if (influencer.categories != null && influencer.categories!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: influencer.categories!.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              // 상태
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(influencer.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(influencer.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(influencer.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      return '${(followers / 10000).toStringAsFixed(1)}만명';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}천명';  
    }
    return '${followers}명';
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.grey;
      case UserStatus.suspended:
        return Colors.red;
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return '활성';
      case UserStatus.inactive:
        return '비활성';
      case UserStatus.suspended:
        return '정지';
    }
  }
}
