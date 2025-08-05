import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class InfluencerCard extends StatelessWidget {
  final User influencer;
  final VoidCallback? onTap;

  const InfluencerCard({
    super.key,
    required this.influencer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지와 인증 배지
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.grey200,
                        backgroundImage: influencer.profileImage != null
                            ? CachedNetworkImageProvider(influencer.profileImage!)
                            : null,
                        child: influencer.profileImage == null
                            ? Text(
                                influencer.nickname?.substring(0, 1) ?? 
                                influencer.name.substring(0, 1),
                                style: const TextStyle(
                                  color: AppTheme.grey600,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      if (influencer.isProfileVerified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          influencer.nickname ?? influencer.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (influencer.region != null)
                          Text(
                            influencer.region!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.grey500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 팔로워 수
              if (influencer.followersCount != null)
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppTheme.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '팔로워 ${_formatFollowers(influencer.followersCount!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // 카테고리
              if (influencer.categories != null && influencer.categories!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: influencer.categories!.take(2).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 8),
              
              // 가격 정보
              if (influencer.priceAmount != null)
                Text(
                  '${influencer.pricePolicy ?? '건당'} ${currencyFormat.format(influencer.priceAmount!)}원',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              
              const Spacer(),
              
              // 소개
              if (influencer.introduction != null)
                Text(
                  influencer.introduction!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFollowers(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}천';
    }
    return count.toString();
  }
}
