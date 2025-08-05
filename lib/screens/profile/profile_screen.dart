import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../widgets/profile/portfolio_section.dart';
import '../../widgets/profile/sns_section.dart';
import '../../widgets/profile/sns_section.dart' show SnsAccountFormModal;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _introController = TextEditingController();
  final _companyController = TextEditingController();
  final _managerController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedRegion;
  String? _selectedPricePolicy;
  List<String> _selectedCategories = [];
  List<String> _snsAccounts = [];
  int? _followersCount;

  final List<String> _regions = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'
  ];

  final List<String> _categories = [
    '뷰티', '패션', '음식', '여행', '테크', '리뷰', '피트니스', '라이프스타일',
    '육아', '반려동물', '게임', '스포츠', '자동차', '인테리어', '요리'
  ];

  final List<String> _pricePolicies = ['건당', '월정액', '협의'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _nicknameController.text = user.nickname ?? '';
      _phoneController.text = user.phone ?? '';
      _introController.text = user.introduction ?? '';
      _companyController.text = user.company ?? '';
      _managerController.text = user.manager ?? '';
      _priceController.text = user.priceAmount?.toString() ?? '';
      
      _selectedRegion = user.region;
      _selectedPricePolicy = user.pricePolicy;
      _selectedCategories = user.categories ?? [];
      _snsAccounts = user.snsAccounts ?? [];
      _followersCount = user.followersCount;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _introController.dispose();
    _companyController.dispose();
    _managerController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // TODO: 이미지 업로드 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 기능은 준비 중입니다.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: 프로필 저장 API 호출
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프로필이 저장되었습니다.'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  // 포트폴리오 관련 메서드
  void _showPortfolioForm({PortfolioItem? item}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item == null ? '포트폴리오 추가 기능은 곧 구현됩니다' : '포트폴리오 편집 기능은 곧 구현됩니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deletePortfolioItem(PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포트폴리오 삭제'),
        content: Text('${item.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('포트폴리오가 삭제되었습니다')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // SNS 관련 메서드
  void _showSnsForm({SnsAccount? account}) {
    showDialog(
      context: context,
      builder: (context) => SnsAccountFormModal(
        account: account,
        onSave: (newAccount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(account == null 
                  ? 'SNS 계정이 추가되었습니다' 
                  : 'SNS 계정이 수정되었습니다'),
            ),
          );
        },
      ),
    );
  }

  void _deleteSnsAccount(SnsAccount account) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SNS 계정이 삭제되었습니다')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.grey200,
                      backgroundImage: user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : null,
                      child: user?.profileImage == null
                          ? Text(
                              user?.name.substring(0, 1) ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.grey600,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 기본 정보
              _SectionTitle(title: '기본 정보'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              if (user?.type == UserType.influencer) ...[
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '활동명 (닉네임)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '휴대폰 번호',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // 지역 선택
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: '지역',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: _regions.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              if (user?.type == UserType.influencer) ...[
                // 인플루언서 전용 정보
                _SectionTitle(title: '인플루언서 정보'),
                const SizedBox(height: 16),

                // 카테고리 선택
                const Text('활동 카테고리', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 팔로워 수
                TextFormField(
                  initialValue: _followersCount?.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '팔로워 수',
                    prefixIcon: Icon(Icons.people_outline),
                    suffixText: '명',
                  ),
                  onChanged: (value) {
                    _followersCount = int.tryParse(value);
                  },
                ),

                const SizedBox(height: 16),

                // 가격 정책
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedPricePolicy,
                        decoration: const InputDecoration(
                          labelText: '가격 정책',
                        ),
                        items: _pricePolicies.map((policy) {
                          return DropdownMenuItem(
                            value: policy,
                            child: Text(policy),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPricePolicy = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '금액',
                          suffixText: '원',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 자기소개
                TextFormField(
                  controller: _introController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '자기소개',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
              ] else ...[
                // 판매사 전용 정보
                _SectionTitle(title: '회사 정보'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: '회사명',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _managerController,
                  decoration: const InputDecoration(
                    labelText: '담당자명',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 인플루언서 전용 섹션
              if (user?.type == UserType.influencer) ...[
                PortfolioSection(
                  portfolioItems: user?.portfolio,
                  onAddPortfolio: () => _showPortfolioForm(),
                  onEditPortfolio: (item) => _showPortfolioForm(item: item),
                  onDeletePortfolio: (item) => _deletePortfolioItem(item),
                ),
                
                const SizedBox(height: 32),
                
                SnsSection(
                  snsAccounts: user?.snsLinks,
                  onAddSns: () => _showSnsForm(),
                  onEditSns: (account) => _showSnsForm(account: account),
                  onDeleteSns: (account) => _deleteSnsAccount(account),
                ),
                
                const SizedBox(height: 32),
              ],

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('저장'),
                ),
              ),

              const SizedBox(height: 16),

              // 인증 상태
              _SectionTitle(title: '인증 상태'),
              const SizedBox(height: 16),
              
              _VerificationItem(
                title: '이메일 인증',
                isVerified: user?.isEmailVerified ?? false,
                onTap: () {
                  // TODO: 이메일 인증
                },
              ),
              
              _VerificationItem(
                title: '휴대폰 인증',
                isVerified: user?.isPhoneVerified ?? false,
                onTap: () {
                  // TODO: 휴대폰 인증
                },
              ),
              
              _VerificationItem(
                title: '프로필 인증',
                isVerified: user?.isProfileVerified ?? false,
                onTap: () {
                  // TODO: 프로필 인증 요청
                },
              ),

              if (user?.type == UserType.seller)
                _VerificationItem(
                  title: '사업자 인증',
                  isVerified: user?.isBusinessVerified ?? false,
                  onTap: () {
                    // TODO: 사업자 인증
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String title;
  final bool isVerified;
  final VoidCallback onTap;

  const _VerificationItem({
    required this.title,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isVerified ? AppTheme.secondaryColor : AppTheme.grey400,
            ),
            const SizedBox(width: 8),
            if (!isVerified)
              TextButton(
                onPressed: onTap,
                child: const Text('인증하기'),
              ),
          ],
        ),
      ),
    );
  }
}
