import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/campaign_model.dart';
import '../utils/theme.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('MM/dd');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 배지와 제목
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(status: campaign.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 설명
              Text(
                campaign.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 카테고리
              if (campaign.categories.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: campaign.categories.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 12),
              
              // 예산과 기간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppTheme.grey500,
                      ),
                      Text(
                        '${currencyFormat.format(campaign.budget)}원',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(campaign.startDate)} ~ ${dateFormat.format(campaign.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 지원자 수
              if (campaign.applicantIds.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppTheme.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${campaign.applicantIds.length}명 지원',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CampaignStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case CampaignStatus.recruiting:
        backgroundColor = AppTheme.secondaryColor;
        textColor = Colors.white;
        label = '모집중';
        break;
      case CampaignStatus.active:
        backgroundColor = AppTheme.primaryColor;
        textColor = Colors.white;
        label = '진행중';
        break;
      case CampaignStatus.completed:
        backgroundColor = AppTheme.grey400;
        textColor = Colors.white;
        label = '완료';
        break;
      case CampaignStatus.cancelled:
        backgroundColor = AppTheme.errorColor;
        textColor = Colors.white;
        label = '취소';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
