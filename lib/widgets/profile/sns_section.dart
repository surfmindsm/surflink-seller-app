import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class SnsSection extends StatelessWidget {
  final List<SnsAccount>? snsAccounts;
  final VoidCallback? onAddSns;
  final Function(SnsAccount)? onEditSns;
  final Function(SnsAccount)? onDeleteSns;

  const SnsSection({
    Key? key,
    this.snsAccounts,
    this.onAddSns,
    this.onEditSns,
    this.onDeleteSns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SNS 계정',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (onAddSns != null)
              TextButton.icon(
                onPressed: onAddSns,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('추가'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // SNS 목록
        if (snsAccounts == null || snsAccounts!.isEmpty)
          _buildEmptyState(context)
        else
          _buildSnsAccountList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.share_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'SNS 계정을 연동하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '인스타그램, 유튜브 등 SNS 계정으로 더 많은 노출 기회를 얻으세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (onAddSns != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddSns,
              icon: const Icon(Icons.add),
              label: const Text('SNS 계정 추가'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSnsAccountList(BuildContext context) {
    return Column(
      children: snsAccounts!.map((account) {
        return _SnsAccountCard(
          account: account,
          onEdit: onEditSns != null ? () => onEditSns!(account) : null,
          onDelete: onDeleteSns != null ? () => onDeleteSns!(account) : null,
        );
      }).toList(),
    );
  }
}

class _SnsAccountCard extends StatelessWidget {
  final SnsAccount account;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SnsAccountCard({
    Key? key,
    required this.account,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getSnsColor(account.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSnsIcon(account.type),
              color: _getSnsColor(account.type),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Text(
                account.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (account.isVerified) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.blue[600],
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${account.username}'),
              if (account.followersCount != null)
                Text(
                  '팔로워 ${_formatNumber(account.followersCount!)}명',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _openSnsUrl(context),
                icon: const Icon(Icons.open_in_new),
                iconSize: 20,
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: () => _showDeleteConfirm(context),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSnsIcon(SnsType type) {
    switch (type) {
      case SnsType.instagram:
        return Icons.camera_alt;
      case SnsType.youtube:
        return Icons.play_circle_fill;
      case SnsType.tiktok:
        return Icons.music_video;
      case SnsType.facebook:
        return Icons.facebook;
      case SnsType.twitter:
        return Icons.alternate_email;
      case SnsType.blog:
        return Icons.edit_note;
      case SnsType.other:
        return Icons.link;
    }
  }

  Color _getSnsColor(SnsType type) {
    switch (type) {
      case SnsType.instagram:
        return const Color(0xFFE4405F);
      case SnsType.youtube:
        return const Color(0xFFFF0000);
      case SnsType.tiktok:
        return const Color(0xFF000000);
      case SnsType.facebook:
        return const Color(0xFF1877F2);
      case SnsType.twitter:
        return const Color(0xFF1DA1F2);
      case SnsType.blog:
        return const Color(0xFF00AA6C);
      case SnsType.other:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  void _openSnsUrl(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SNS 링크: ${account.url}'),
        action: SnackBarAction(
          label: '복사',
          onPressed: () {
            // 클립보드에 복사하는 기능은 추후 구현
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크가 복사되었습니다')),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SNS 계정 삭제'),
        content: Text('${account.displayName} 계정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete!();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// SNS 계정 추가/편집 모달
class SnsAccountFormModal extends StatefulWidget {
  final SnsAccount? account;
  final Function(SnsAccount) onSave;

  const SnsAccountFormModal({
    Key? key,
    this.account,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SnsAccountFormModal> createState() => _SnsAccountFormModalState();
}

class _SnsAccountFormModalState extends State<SnsAccountFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();
  final _followersController = TextEditingController();

  SnsType _selectedType = SnsType.instagram;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _usernameController.text = widget.account!.username;
      _urlController.text = widget.account!.url;
      _followersController.text = 
          widget.account!.followersCount?.toString() ?? '';
      _selectedType = widget.account!.type;
      _isVerified = widget.account!.isVerified;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _urlController.dispose();
    _followersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'SNS 계정 추가' : 'SNS 계정 수정'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 플랫폼 선택
              DropdownButtonFormField<SnsType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'SNS 플랫폼',
                  border: OutlineInputBorder(),
                ),
                items: SnsType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getSnsIcon(type), color: _getSnsColor(type)),
                        const SizedBox(width: 8),
                        Text(_getDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 사용자명
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자명',
                  border: OutlineInputBorder(),
                  prefixText: '@',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자명을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 팔로워 수
              TextFormField(
                controller: _followersController,
                decoration: const InputDecoration(
                  labelText: '팔로워 수 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // 인증 여부
              CheckboxListTile(
                title: const Text('인증된 계정'),
                value: _isVerified,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('저장'),
        ),
      ],
    );
  }

  IconData _getSnsIcon(SnsType type) {
    switch (type) {
      case SnsType.instagram:
        return Icons.camera_alt;
      case SnsType.youtube:
        return Icons.play_circle_fill;
      case SnsType.tiktok:
        return Icons.music_video;
      case SnsType.facebook:
        return Icons.facebook;
      case SnsType.twitter:
        return Icons.alternate_email;
      case SnsType.blog:
        return Icons.edit_note;
      case SnsType.other:
        return Icons.link;
    }
  }

  Color _getSnsColor(SnsType type) {
    switch (type) {
      case SnsType.instagram:
        return const Color(0xFFE4405F);
      case SnsType.youtube:
        return const Color(0xFFFF0000);
      case SnsType.tiktok:
        return const Color(0xFF000000);
      case SnsType.facebook:
        return const Color(0xFF1877F2);
      case SnsType.twitter:
        return const Color(0xFF1DA1F2);
      case SnsType.blog:
        return const Color(0xFF00AA6C);
      case SnsType.other:
        return Colors.grey;
    }
  }

  String _getDisplayName(SnsType type) {
    switch (type) {
      case SnsType.instagram:
        return 'Instagram';
      case SnsType.youtube:
        return 'YouTube';
      case SnsType.tiktok:
        return 'TikTok';
      case SnsType.facebook:
        return 'Facebook';
      case SnsType.twitter:
        return 'Twitter';
      case SnsType.blog:
        return 'Blog';
      case SnsType.other:
        return 'Other';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final account = SnsAccount(
      id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      username: _usernameController.text,
      url: _urlController.text,
      followersCount: int.tryParse(_followersController.text),
      isVerified: _isVerified,
      verifiedAt: _isVerified ? DateTime.now() : null,
    );

    widget.onSave(account);
    Navigator.pop(context);
  }
}
