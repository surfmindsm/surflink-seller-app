import 'package:flutter/material.dart';
import '../../models/verification_model.dart';
import '../../utils/theme.dart';

/// 인증 카드 위젯
class VerificationCard extends StatelessWidget {
  final VerificationInfo verification;
  final VoidCallback? onTap;
  final bool showDetails;

  const VerificationCard({
    Key? key,
    required this.verification,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // 인증 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: verification.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: verification.statusColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 인증 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              verification.typeName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusDescription(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 상태 아이콘
                  Icon(
                    verification.statusIcon,
                    color: verification.statusColor,
                    size: 20,
                  ),
                ],
              ),
              
              // 세부 정보 (showDetails가 true일 때)
              if (showDetails && _hasDetails()) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildDetailsSection(context),
              ],
              
              // 거절 사유 (거절된 경우)
              if (verification.isRejected && verification.rejectReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '거절 사유',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verification.rejectReason!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 인증 타입별 아이콘
  IconData _getTypeIcon() {
    switch (verification.type) {
      case VerificationType.identity:
        return Icons.person;
      case VerificationType.business:
        return Icons.business;
      case VerificationType.phone:
        return Icons.phone;
      case VerificationType.email:
        return Icons.email;
      case VerificationType.sns:
        return Icons.share;
      case VerificationType.portfolio:
        return Icons.work;
      case VerificationType.followers:
        return Icons.people;
      case VerificationType.address:
        return Icons.location_on;
    }
  }

  /// 상태 칩 빌드
  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: verification.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        verification.statusText,
        style: TextStyle(
          color: verification.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 상태 설명 텍스트
  String _getStatusDescription() {
    switch (verification.status) {
      case VerificationStatus.notStarted:
        return '인증을 시작하려면 탭하세요';
      case VerificationStatus.pending:
        return '관리자 검토 중입니다';
      case VerificationStatus.approved:
        final approvedAt = verification.approvedAt;
        if (approvedAt != null) {
          return '${approvedAt.month}/${approvedAt.day} 인증 완료';
        }
        return '인증이 완료되었습니다';
      case VerificationStatus.rejected:
        return '인증이 거절되었습니다. 다시 시도해보세요';
      case VerificationStatus.expired:
        return '인증이 만료되었습니다. 다시 인증하세요';
    }
  }

  /// 세부 정보 존재 여부
  bool _hasDetails() {
    return verification.metadata != null && verification.metadata!.isNotEmpty ||
           verification.documents != null && verification.documents!.isNotEmpty;
  }

  /// 세부 정보 섹션 빌드
  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메타데이터 표시
        if (verification.metadata != null && verification.metadata!.isNotEmpty)
          _buildMetadataSection(context),
        
        // 첨부 문서 표시
        if (verification.documents != null && verification.documents!.isNotEmpty) ...[
          if (verification.metadata != null && verification.metadata!.isNotEmpty)
            const SizedBox(height: 12),
          _buildDocumentsSection(context),
        ],
        
        // 제출일/승인일 표시
        if (verification.submittedAt != null || verification.approvedAt != null)
          _buildDatesSection(context),
      ],
    );
  }

  /// 메타데이터 섹션
  Widget _buildMetadataSection(BuildContext context) {
    final metadata = verification.metadata!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인증 정보',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...metadata.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    _formatMetadataKey(entry.key),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 문서 섹션
  Widget _buildDocumentsSection(BuildContext context) {
    final documents = verification.documents!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '첨부 문서',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...documents.map((doc) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  doc.isImage ? Icons.image : Icons.attach_file,
                  size: 16,
                  color: AppTheme.grey600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doc.fileName,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  doc.formattedFileSize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 날짜 섹션
  Widget _buildDatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (verification.submittedAt != null)
          _buildDateItem(context, '제출일', verification.submittedAt!),
        if (verification.approvedAt != null)
          _buildDateItem(context, '승인일', verification.approvedAt!),
      ],
    );
  }

  /// 날짜 아이템
  Widget _buildDateItem(BuildContext context, String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 메타데이터 키 포맷팅
  String _formatMetadataKey(String key) {
    switch (key) {
      case 'phone':
        return '휴대폰';
      case 'email':
        return '이메일';
      case 'name':
        return '이름';
      case 'birth_date':
        return '생년월일';
      case 'gender':
        return '성별';
      case 'business_number':
        return '사업자번호';
      case 'business_name':
        return '상호';
      case 'owner_name':
        return '대표자명';
      case 'platform':
        return '플랫폼';
      case 'account':
        return '계정';
      case 'followers_count':
        return '팔로워 수';
      case 'verified_followers':
        return '검증 팔로워';
      case 'description':
        return '설명';
      case 'file_count':
        return '파일 수';
      default:
        return key;
    }
  }
}
