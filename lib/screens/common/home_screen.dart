import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
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
      _SearchTab(),
      _ChatTab(),
      _ProfileTab(user: user),
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
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: 알림 화면 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 기능은 준비 중입니다.')),
                );
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
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
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '검색',
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

class _HomeTab extends StatelessWidget {
  final User? user;

  const _HomeTab({this.user});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await userProvider.loadCampaigns();
            await userProvider.loadInfluencers();
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
                            user?.name.substring(0, 1) ?? 'U',
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
                                '${user?.name ?? '사용자'}님, 안녕하세요!',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.type == UserType.seller 
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
                        title: user?.type == UserType.seller 
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
                        title: user?.type == UserType.seller 
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
                if (user?.type == UserType.seller) ...[
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
                
                if (user?.type == UserType.seller) ...[
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

class _SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '검색 기능은 준비 중입니다.',
        style: TextStyle(fontSize: 16),
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
