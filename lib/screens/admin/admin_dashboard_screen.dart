import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';

/// 관리자 대시보드 화면
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  AdminDashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSystemSettings(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
      drawer: _buildAdminDrawer(),
    );
  }

  /// 대시보드 통계 로드
  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('통계를 불러오는데 실패했습니다.');
    }
  }

  /// 대시보드 구성
  Widget _buildDashboard() {
    if (_stats == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주요 통계
          _buildMainStats(),
          const SizedBox(height: 24),

          // 대기 중인 작업
          _buildPendingTasks(),
          const SizedBox(height: 24),

          // 차트 섹션
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 일일 통계 차트
              Expanded(
                flex: 2,
                child: _buildDailyStatsChart(),
              ),
              const SizedBox(width: 16),

              // 카테고리별 통계
              Expanded(
                child: _buildCategoryStats(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 빠른 작업 메뉴
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// 주요 통계 카드
  Widget _buildMainStats() {
    final stats = _stats!;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: '전체 사용자',
          value: '${stats.totalUsers}',
          subtitle: '활성: ${stats.activeUsers}',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: '전체 캠페인',
          value: '${stats.totalCampaigns}',
          subtitle: '활성: ${stats.activeCampaigns}',
          icon: Icons.campaign,
          color: Colors.green,
        ),
        _buildStatCard(
          title: '이번 달 수익',
          value: '${(stats.monthlyRevenue / 1000000).toStringAsFixed(1)}M',
          subtitle: '전체: ${(stats.totalRevenue / 100000000).toStringAsFixed(1)}억',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: '대기 작업',
          value: '${stats.pendingVerifications + stats.pendingReports}',
          subtitle: '인증: ${stats.pendingVerifications}, 신고: ${stats.pendingReports}',
          icon: Icons.pending_actions,
          color: Colors.red,
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 대기 중인 작업
  Widget _buildPendingTasks() {
    final stats = _stats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '대기 중인 작업',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildPendingTaskItem(
                    title: '인증 요청',
                    count: stats.pendingVerifications,
                    icon: Icons.verified_user,
                    color: Colors.blue,
                    onTap: () => context.push('/admin/verifications'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPendingTaskItem(
                    title: '신고 처리',
                    count: stats.pendingReports,
                    icon: Icons.report,
                    color: Colors.red,
                    onTap: () => context.push('/admin/reports'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 대기 작업 항목
  Widget _buildPendingTaskItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count건 대기',
                    style: TextStyle(
                      color: count > 0 ? color : AppTheme.grey600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  /// 일일 통계 차트 (간단한 리스트로 표시)
  Widget _buildDailyStatsChart() {
    final stats = _stats!;
    final recentStats = stats.dailyStats.take(7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 7일 통계',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...recentStats.map((stat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${stat.date.month}/${stat.date.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '신규 사용자: ${stat.newUsers}명',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '신규 캠페인: ${stat.newCampaigns}개',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '수익: ${(stat.revenue / 1000000).toStringAsFixed(1)}M원',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// 카테고리별 통계
  Widget _buildCategoryStats() {
    final stats = _stats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 현황',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...stats.categoryStats.take(6).map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('${category.campaignCount}개'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: category.campaignCount / 100,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '평균 평점: ${category.averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// 빠른 작업 메뉴
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '빠른 작업',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionItem(
                  icon: Icons.people_outline,
                  label: '사용자 관리',
                  onTap: () => context.push('/admin/users'),
                ),
                _buildQuickActionItem(
                  icon: Icons.campaign_outlined,
                  label: '캠페인 관리',
                  onTap: () => context.push('/admin/campaigns'),
                ),
                _buildQuickActionItem(
                  icon: Icons.report_outlined,
                  label: '신고 관리',
                  onTap: () => context.push('/admin/reports'),
                ),
                _buildQuickActionItem(
                  icon: Icons.verified_user_outlined,
                  label: '인증 관리',
                  onTap: () => context.push('/admin/verifications'),
                ),
                _buildQuickActionItem(
                  icon: Icons.announcement_outlined,
                  label: '공지사항',
                  onTap: () => _createAnnouncement(),
                ),
                _buildQuickActionItem(
                  icon: Icons.download_outlined,
                  label: '데이터 내보내기',
                  onTap: () => _exportData(),
                ),
                _buildQuickActionItem(
                  icon: Icons.history_outlined,
                  label: '시스템 로그',
                  onTap: () => context.push('/admin/logs'),
                ),
                _buildQuickActionItem(
                  icon: Icons.settings_outlined,
                  label: '시스템 설정',
                  onTap: () => _showSystemSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 빠른 작업 항목
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 관리자 네비게이션 드로어
  Widget _buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  '셀러셀러 관리자',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('대시보드'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('사용자 관리'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/users');
            },
          ),

          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('캠페인 관리'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/campaigns');
            },
          ),

          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('신고 관리'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/reports');
            },
          ),

          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('인증 관리'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/verifications');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('시스템 설정'),
            onTap: () {
              Navigator.pop(context);
              _showSystemSettings();
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('시스템 로그'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/logs');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  // 액션 메서드들
  void _createAnnouncement() {
    _showInfoSnackBar('공지사항 작성 기능은 곧 추가됩니다.');
  }

  void _exportData() {
    _showInfoSnackBar('데이터 내보내기 기능은 곧 추가됩니다.');
  }

  void _showSystemSettings() {
    _showInfoSnackBar('시스템 설정 기능은 곧 추가됩니다.');
  }

  // 스낵바 메서드들
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
