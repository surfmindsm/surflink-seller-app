import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/security_model.dart';
import '../../services/security_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

/// 보안 설정 화면
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen>
    with SingleTickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  SecuritySettings? _securitySettings;
  bool _isLoading = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSecuritySettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('보안 설정')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('보안 설정'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '보안', icon: Icon(Icons.security)),
            Tab(text: '알림', icon: Icon(Icons.notifications)),
            Tab(text: '개인정보', icon: Icon(Icons.privacy_tip)),
            Tab(text: '기기', icon: Icon(Icons.devices)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSecurityTab(),
                _buildNotificationTab(),
                _buildPrivacyTab(),
                _buildDevicesTab(),
              ],
            ),
    );
  }

  /// 보안 설정 로드
  Future<void> _loadSecuritySettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final settings = await _securityService.getSecuritySettings(user.id);
      setState(() {
        _securitySettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('보안 설정을 불러오는데 실패했습니다.');
    }
  }

  /// 보안 탭
  Widget _buildSecurityTab() {
    if (_securitySettings == null) return const SizedBox();
    final settings = _securitySettings!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 보안 점수 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: _getSecurityColor(settings.securityLevel), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('보안 강도', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(settings.securityLevel.label, style: TextStyle(color: _getSecurityColor(settings.securityLevel), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Text('${settings.securityScore}/100', style: TextStyle(fontSize: 24, color: _getSecurityColor(settings.securityLevel), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: settings.securityScore / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(_getSecurityColor(settings.securityLevel)),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 인증 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('인증 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    secondary: const Icon(Icons.security),
                    title: const Text('2차 인증 (2FA)'),
                    subtitle: const Text('로그인 시 추가 인증 단계를 거칩니다'),
                    value: settings.isTwoFactorEnabled,
                    onChanged: (value) => _toggleTwoFactorAuth(value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),

                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('생체 인증'),
                    subtitle: const Text('지문이나 얼굴 인식으로 로그인합니다'),
                    value: settings.isBiometricEnabled,
                    onChanged: (value) => _toggleBiometricAuth(value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),

                  ListTile(
                    leading: Icon(Icons.lock),
                    title: const Text('비밀번호 변경'),
                    subtitle: settings.lastPasswordChanged != null 
                        ? Text('마지막 변경: ${_formatDate(settings.lastPasswordChanged!)}')
                        : const Text('비밀번호를 변경해주세요'),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: _changePassword,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 알림 탭
  Widget _buildNotificationTab() {
    if (_securitySettings == null) return const SizedBox();
    final settings = _securitySettings!.notificationSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('알림 방식', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('푸시 알림'),
                    value: settings.enablePushNotifications,
                    onChanged: (value) => _updateNotificationSettings(settings.copyWith(enablePushNotifications: value)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    secondary: const Icon(Icons.email),
                    title: const Text('이메일 알림'),
                    value: settings.enableEmailNotifications,
                    onChanged: (value) => _updateNotificationSettings(settings.copyWith(enableEmailNotifications: value)),
                    contentPadding: EdgeInsets.zero,
                  ),

                  SwitchListTile(
                    secondary: const Icon(Icons.sms),
                    title: const Text('SMS 알림'),
                    value: settings.enableSmsNotifications,
                    onChanged: (value) => _updateNotificationSettings(settings.copyWith(enableSmsNotifications: value)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개인정보 탭
  Widget _buildPrivacyTab() {
    if (_securitySettings == null) return const SizedBox();
    final settings = _securitySettings!.privacySettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('공개 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('프로필 공개 범위'),
                    subtitle: Text(settings.profileVisibility.label),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _editProfileVisibility(settings),
                  ),
                  const Divider(),

                  SwitchListTile(
                    title: const Text('온라인 상태 표시'),
                    value: settings.showOnlineStatus,
                    onChanged: (value) => _updatePrivacySettings(settings.copyWith(showOnlineStatus: value)),
                    contentPadding: EdgeInsets.zero,
                  ),

                  SwitchListTile(
                    title: const Text('최종 접속 시간 표시'),
                    value: settings.showLastSeen,
                    onChanged: (value) => _updatePrivacySettings(settings.copyWith(showLastSeen: value)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 계정 삭제
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
                subtitle: const Text('계정을 영구적으로 삭제합니다.'),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                contentPadding: EdgeInsets.zero,
                onTap: _deleteAccount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 기기 탭
  Widget _buildDevicesTab() {
    return FutureBuilder<List<LoginDevice>>(
      future: _securityService.getLoginDevices(_securitySettings!.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('등록된 기기가 없습니다.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('로그인 기기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  ...snapshot.data!.map((device) => ListTile(
                    leading: Icon(_getDeviceIcon(device.deviceType)),
                    title: Row(
                      children: [
                        Expanded(child: Text(device.deviceName)),
                        if (device.isCurrentDevice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('현재 기기', style: TextStyle(fontSize: 10)),
                          ),
                      ],
                    ),
                    subtitle: Text('${device.osVersion} • ${device.location}'),
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 헬퍼 메서드들
  Color _getSecurityColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.veryLow: return Colors.red;
      case SecurityLevel.low: return Colors.orange;
      case SecurityLevel.medium: return Colors.yellow.shade700;
      case SecurityLevel.high: return Colors.green;
    }
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile': return Icons.phone_android;
      case 'desktop': return Icons.computer;
      case 'tablet': return Icons.tablet;
      default: return Icons.device_unknown;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 액션 메서드들
  Future<void> _toggleTwoFactorAuth(bool value) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final success = await _securityService.toggleTwoFactorAuth(user.id, value);
      if (success) {
        await _loadSecuritySettings();
        _showSuccessSnackBar(value ? '2차 인증이 활성화되었습니다.' : '2차 인증이 비활성화되었습니다.');
      } else {
        _showErrorSnackBar('2차 인증 설정에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('오류가 발생했습니다.');
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    // 목업 구현
    setState(() {
      _securitySettings = _securitySettings?.copyWith(isBiometricEnabled: value);
    });
    _showSuccessSnackBar(value ? '생체 인증이 활성화되었습니다.' : '생체 인증이 비활성화되었습니다.');
  }

  void _changePassword() {
    _showInfoSnackBar('비밀번호 변경 기능은 곧 추가됩니다.');
  }

  Future<void> _updateNotificationSettings(NotificationSettings settings) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      await _securityService.updateNotificationSettings(user.id, settings);
      setState(() {
        _securitySettings = _securitySettings?.copyWith(notificationSettings: settings);
      });
    } catch (e) {
      _showErrorSnackBar('설정 저장에 실패했습니다.');
    }
  }

  Future<void> _updatePrivacySettings(PrivacySettings settings) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      await _securityService.updatePrivacySettings(user.id, settings);
      setState(() {
        _securitySettings = _securitySettings?.copyWith(privacySettings: settings);
      });
    } catch (e) {
      _showErrorSnackBar('설정 저장에 실패했습니다.');
    }
  }

  void _editProfileVisibility(PrivacySettings settings) {
    _showInfoSnackBar('프로필 공개 범위 설정 기능은 곧 추가됩니다.');
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text('정말로 계정을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showInfoSnackBar('계정 삭제 기능은 곧 추가됩니다.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 스낵바 메서드들
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}
