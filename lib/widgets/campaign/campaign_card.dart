import 'package:flutter/material.dart';
import '../../models/campaign_model.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignCard({
    Key? key,
    required this.campaign,
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
              // 캠페인 제목
              Text(
                campaign.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),



              // 카테고리
              if (campaign.categories.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: campaign.categories.take(3).map((category) {
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

              // 예산 및 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 예산
                  if (campaign.budget > 0)
                    Text(
                      '${_formatPrice(campaign.budget.toDouble())}원',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                  // 상태
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(campaign.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(campaign.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(campaign.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // 설명 (있을 경우)
              if (campaign.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  campaign.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000) {
      return '${(price / 10000).toInt()}만';
    }
    return price.toInt().toString();
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.recruiting:
        return Colors.orange;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.completed:
        return Colors.blue;
      case CampaignStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.recruiting:
        return '모집중';
      case CampaignStatus.active:
        return '진행중';
      case CampaignStatus.completed:
        return '완료';
      case CampaignStatus.cancelled:
        return '취소';
    }
  }
}
