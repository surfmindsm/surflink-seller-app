import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/campaign_card.dart';
import '../../widgets/influencer_card.dart';
import '../contract/contract_list_screen.dart';
import '../review/review_list_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 데이터 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadCampaigns();
      Provider.of<UserProvider>(context, listen: false).loadInfluencers();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = authProvider.user;

    final List<Widget> pages = [
      _HomeTab(user: user),
      const ContractListScreen(),
      const ReviewListScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.connect_without_contact,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('셀러셀러'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.push('/search?targetType=campaign');
              },
            ),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        context.push('/notifications');
                      },
                    ),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.grey400,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              activeIcon: Icon(Icons.description),
              label: '계약',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: '리뷰',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final User? user;

  const _HomeTab({this.user});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    if (widget.user != null) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.loadAllDashboardData(widget.user!.id, widget.user!.type);
    }
  }

  // 활동 타입별 색상 반환
  Color _getActivityColor(String type) {
    switch (type) {
      case 'campaign':
        return Colors.blue;
      case 'match':
        return Colors.green;
      case 'application':
        return Colors.orange;
      case 'review':
        return Colors.purple;
      case 'chat':
        return Colors.teal;
      case 'contract':
        return Colors.indigo;
      default:
        return AppTheme.grey500;
    }
  }

  // 활동 타입별 아이콘 반환
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'campaign':
        return Icons.campaign;
      case 'match':
        return Icons.people;
      case 'application':
        return Icons.assignment;
      case 'review':
        return Icons.star;
      case 'chat':
        return Icons.chat;
      case 'contract':
        return Icons.description;
      default:
        return Icons.info;
    }
  }

  // 활동 시간 포맷팅
  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, DashboardProvider>(
      builder: (context, userProvider, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await userProvider.loadCampaigns();
            await userProvider.loadInfluencers();
            if (widget.user != null) {
              await dashboardProvider.refresh(widget.user!.id, widget.user!.type);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 환영 메시지 & 간단 통계
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: Text(
                                widget.user?.name.substring(0, 1) ?? 'U',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.user?.name ?? '사용자'}님, 안녕하세요!',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.user?.type == UserType.seller 
                                        ? '새로운 인플루언서를 찾아보세요'
                                        : '새로운 캠페인에 참여해보세요',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 간단 통계
                        Consumer<DashboardProvider>(
                          builder: (context, dashboardProvider, child) {
                            if (widget.user == null || dashboardProvider.isLoadingStats) {
                              return const SizedBox.shrink();
                            }
                            final stats = dashboardProvider.stats;
                            if (stats == null) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _StatItem(
                                    label: '이번 달',
                                    value: stats.thisMonthEarnings > 0 
                                        ? '${(stats.thisMonthEarnings / 10000).toStringAsFixed(0)}만원'
                                        : '${stats.totalCampaigns}개',
                                    icon: widget.user?.type == UserType.seller 
                                        ? Icons.campaign
                                        : Icons.work,
                                  ),
                                  _StatItem(
                                    label: '진행 중',
                                    value: '${stats.activeCampaigns}개',
                                    icon: Icons.trending_up,
                                  ),
                                  _StatItem(
                                    label: '평점',
                                    value: stats.averageRating > 0 
                                        ? '${stats.averageRating.toStringAsFixed(1)}점'
                                        : 'N/A',
                                    icon: Icons.star,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 공지사항 (있는 경우만 표시)
                if (widget.user?.type == UserType.seller || widget.user?.type == UserType.influencer) ...<Widget>[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🎉 신규 가입 이벤트',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '첫 협업 완료 시 수수료 50% 할인!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            onPressed: () {
                              // TODO: 공지사항 상세로 이동
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 최근 활동
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최근 활동',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/notifications');
                      },
                      child: const Text('더보기'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Consumer<DashboardProvider>(
                  builder: (context, dashboardProvider, child) {
                    if (widget.user == null || dashboardProvider.isLoadingRecentActivities) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    
                    final activities = dashboardProvider.recentActivities ?? [];
                    if (activities.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('최근 활동이 없습니다.'),
                          ),
                        ),
                      );
                    }
                    
                    return Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.take(3).length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getActivityColor(activity.type),
                              child: Icon(
                                _getActivityIcon(activity.type),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              activity.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              activity.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatActivityTime(activity.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey600,
                              ),
                            ),
                            onTap: () {
                              // TODO: 확인 버튼 없이 기본 네비게이션 처리
                              if (activity.type == 'campaign') {
                                context.push('/campaigns');
                              } else if (activity.type == 'match') {
                                context.push('/auto-match');
                              } else if (activity.type == 'review') {
                                context.push('/review/list');
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 빠른 메뉴
                Row(
                  children: [
                    Expanded(
                      child: _QuickMenuCard(
                        icon: Icons.campaign,
                        title: widget.user?.type == UserType.seller 
                            ? '캠페인 등록'
                            : '캠페인 찾기',
                        onTap: () {
                          context.push('/campaigns');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickMenuCard(
                        icon: Icons.people,
                        title: widget.user?.type == UserType.seller 
                            ? '인플루언서 검색'
                            : '프로필 관리',
                        onTap: () {
                          context.push('/profile');
                        },
                      ),
                    ),
                  ],
                ),
                
                // 자동매칭 (판매사 전용)
                if (widget.user?.type == UserType.seller) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _QuickMenuCard(
                      icon: Icons.auto_awesome,
                      title: '🤖 AI 자동매칭',
                      subtitle: 'AI가 최적의 인플루언서를 찾아드립니다',
                      onTap: () {
                        context.push('/auto-match');
                      },
                      isHighlight: true,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 최신 캠페인
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최신 캠페인',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/campaigns');
                      },
                      child: const Text('더보기'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (userProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (userProvider.campaigns.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('아직 캠페인이 없습니다.'),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userProvider.campaigns.take(5).length,
                      itemBuilder: (context, index) {
                        final campaign = userProvider.campaigns[index];
                        return Container(
                          width: 300,
                          margin: EdgeInsets.only(
                            right: index < userProvider.campaigns.length - 1 ? 12 : 0,
                          ),
                          child: CampaignCard(campaign: campaign),
                        );
                      },
                    ),
                  ),
                
                if (widget.user?.type == UserType.seller) ...[
                  const SizedBox(height: 24),
                  
                  // 인플루언서 추천
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '추천 인플루언서',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 인플루언서 검색 화면으로 이동
                        },
                        child: const Text('더보기'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userProvider.influencers.take(5).length,
                      itemBuilder: (context, index) {
                        final influencer = userProvider.influencers[index];
                        return Container(
                          width: 160,
                          margin: EdgeInsets.only(
                            right: index < userProvider.influencers.length - 1 ? 12 : 0,
                          ),
                          child: InfluencerCard(influencer: influencer),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isHighlight;

  const _QuickMenuCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlight ? 4 : 1,
      color: isHighlight ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isHighlight 
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              )
            : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: isHighlight ? 36 : 32,
                  color: isHighlight 
                    ? AppTheme.primaryColor 
                    : AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isHighlight ? FontWeight.bold : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 통계 아이템 위젯
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }
}
