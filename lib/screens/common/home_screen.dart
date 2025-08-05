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
      _ContractTab(),
      _ReviewTab(),
      _ChatTab(),
      _ProfileTab(user: user),
    ];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: '홈'),
              Tab(icon: Icon(Icons.description), text: '계약'),
              Tab(icon: Icon(Icons.star), text: '리뷰'),
              Tab(icon: Icon(Icons.chat), text: '채팅'),
              Tab(icon: Icon(Icons.person), text: '프로필'),
            ],
          ),
        ),
        body: TabBarView(
          children: pages,
        ),
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
                // 환영 메시지
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
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
                  ),
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

class _ContractTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '계약 관리',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '내 계약을 확인하고 관리하세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/contracts'),
            icon: const Icon(Icons.description),
            label: const Text('계약 목록 보기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '리뷰 관리',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '받은 리뷰와 작성한 리뷰를 확인하세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/review/list'),
            icon: const Icon(Icons.star),
            label: const Text('리뷰 목록 보기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            '채팅',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '인플루언서와 실시간으로 소통하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/chat');
            },
            icon: const Icon(Icons.chat),
            label: const Text('채팅 목록 보기'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final User? user;

  const _ProfileTab({this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.push('/profile');
        },
        child: const Text('프로필 설정하기'),
      ),
    );
  }
}
