import 'package:flutter/material.dart';
import '../../models/verification_model.dart';
import '../../utils/theme.dart';

/// 인증 배지 위젯
class VerificationBadgeWidget extends StatelessWidget {
  final List<VerificationBadge> badges;
  final int? maxBadges;
  final double badgeSize;
  final bool showLabels;

  const VerificationBadgeWidget({
    Key? key,
    required this.badges,
    this.maxBadges,
    this.badgeSize = 24,
    this.showLabels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final displayBadges = maxBadges != null 
        ? badges.take(maxBadges!).toList() 
        : badges;
    
    final remainingCount = maxBadges != null && badges.length > maxBadges! 
        ? badges.length - maxBadges! 
        : 0;

    if (showLabels) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...displayBadges.map((badge) => _buildLabeledBadge(context, badge)),
          if (remainingCount > 0) _buildMoreBadge(context, remainingCount),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayBadges.asMap().entries.map((entry) {
            final index = entry.key;
            final badge = entry.value;
            return Padding(
              padding: EdgeInsets.only(left: index > 0 ? -6 : 0),
              child: _buildCircleBadge(badge),
            );
          }),
          if (remainingCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: -6),
              child: _buildMoreCircleBadge(remainingCount),
            ),
        ],
      );
    }
  }

  /// 라벨이 있는 배지
  Widget _buildLabeledBadge(BuildContext context, VerificationBadge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badge.icon,
            color: badge.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            badge.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: badge.color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 원형 배지
  Widget _buildCircleBadge(VerificationBadge badge) {
    return Tooltip(
      message: badge.label,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: badge.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          badge.icon,
          color: Colors.white,
          size: badgeSize * 0.5,
        ),
      ),
    );
  }

  /// 더 많은 배지 표시 (라벨 버전)
  Widget _buildMoreBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.grey300,
          width: 1,
        ),
      ),
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.grey600,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 더 많은 배지 표시 (원형 버전)
  Widget _buildMoreCircleBadge(int count) {
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: AppTheme.grey400,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: badgeSize * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 인증 점수 위젯
class VerificationScoreWidget extends StatelessWidget {
  final UserVerificationStatus verificationStatus;
  final double size;
  final bool showDetails;

  const VerificationScoreWidget({
    Key? key,
    required this.verificationStatus,
    this.size = 80,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = verificationStatus.verificationScore;
    final level = verificationStatus.verificationLevel;
    final completionRate = verificationStatus.completionRate;

    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          
          // 진행률 표시
          SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: CircularProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
              strokeWidth: 3,
            ),
          ),
          
          // 점수 텍스트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                  fontSize: size * 0.2,
                ),
              ),
              if (showDetails)
                Text(
                  level,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getScoreColor(score),
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 점수에 따른 색상 반환
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.purple;      // 플래티넘
    if (score >= 60) return Colors.orange;     // 골드  
    if (score >= 40) return Colors.grey;       // 실버
    if (score >= 20) return Colors.brown;      // 브론즈
    return AppTheme.grey500;                   // 뉴비
  }
}

/// 인증 진행률 위젯  
class VerificationProgressWidget extends StatelessWidget {
  final UserVerificationStatus verificationStatus;
  final bool compact;

  const VerificationProgressWidget({
    Key? key,
    required this.verificationStatus,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount = verificationStatus.completedCount;
    final totalCount = verificationStatus.totalCount;
    final completionRate = verificationStatus.completionRate;

    if (compact) {
      return Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: AppTheme.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completionRate),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$completedCount/$totalCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: _getProgressColor(completionRate),
            ),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '인증 진행률',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${completionRate.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(completionRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: AppTheme.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completionRate),
              ),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount개 인증 완료 (총 $totalCount개)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 12),
            // 인증 배지들
            if (verificationStatus.badges.isNotEmpty)
              VerificationBadgeWidget(
                badges: verificationStatus.badges,
                showLabels: true,
              ),
          ],
        ),
      ),
    );
  }

  /// 진행률에 따른 색상
  Color _getProgressColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.blue;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}
