import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/campaign_model.dart';
import '../../utils/theme.dart';
import '../../widgets/campaign_card.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final _searchController = TextEditingController();
  List<String> _selectedCategories = [];
  CampaignStatus? _selectedStatus;
  RangeValues? _budgetRange;

  final List<String> _categories = [
    '뷰티', '패션', '음식', '여행', '테크', '리뷰', '피트니스', '라이프스타일',
    '육아', '반려동물', '게임', '스포츠', '자동차', '인테리어', '요리'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadCampaigns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Campaign> _getFilteredCampaigns(List<Campaign> campaigns) {
    var filtered = campaigns;

    // 검색어 필터
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((campaign) {
        return campaign.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               campaign.description.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // 카테고리 필터
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((campaign) {
        return campaign.categories.any((cat) => _selectedCategories.contains(cat));
      }).toList();
    }

    // 상태 필터
    if (_selectedStatus != null) {
      filtered = filtered.where((campaign) => campaign.status == _selectedStatus).toList();
    }

    // 예산 필터
    if (_budgetRange != null) {
      filtered = filtered.where((campaign) {
        return campaign.budget >= _budgetRange!.start && 
               campaign.budget <= _budgetRange!.end;
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('필터'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 카테고리 필터
                    const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
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

                    // 상태 필터
                    const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<CampaignStatus?>(
                      value: _selectedStatus,
                      isExpanded: true,
                      hint: const Text('상태 선택'),
                      items: [
                        const DropdownMenuItem<CampaignStatus?>(
                          value: null,
                          child: Text('전체'),
                        ),
                        ...CampaignStatus.values.map((status) {
                          String label;
                          switch (status) {
                            case CampaignStatus.recruiting:
                              label = '모집중';
                              break;
                            case CampaignStatus.active:
                              label = '진행중';
                              break;
                            case CampaignStatus.completed:
                              label = '완료';
                              break;
                            case CampaignStatus.cancelled:
                              label = '취소';
                              break;
                          }
                          return DropdownMenuItem<CampaignStatus?>(
                            value: status,
                            child: Text(label),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 예산 필터
                    const Text('예산 범위', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _budgetRange ?? const RangeValues(500000, 5000000),
                      min: 100000,
                      max: 10000000,
                      divisions: 99,
                      labels: RangeLabels(
                        '${((_budgetRange?.start ?? 500000) / 10000).toInt()}만원',
                        '${((_budgetRange?.end ?? 5000000) / 10000).toInt()}만원',
                      ),
                      onChanged: (values) {
                        setDialogState(() {
                          _budgetRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedStatus = null;
                      _budgetRange = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('초기화'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text('적용'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    final filteredCampaigns = _getFilteredCampaigns(userProvider.campaigns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (user?.type == UserType.seller)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: 캠페인 등록 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('캠페인 등록 기능은 준비 중입니다.')),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '캠페인 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // 필터 칩들
          if (_selectedCategories.isNotEmpty || 
              _selectedStatus != null || 
              _budgetRange != null)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // 카테고리 칩들
                  ..._selectedCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(category),
                        onDeleted: () {
                          setState(() {
                            _selectedCategories.remove(category);
                          });
                        },
                      ),
                    );
                  }),
                  
                  // 상태 칩
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_getStatusLabel(_selectedStatus!)),
                        onDeleted: () {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                    ),
                  
                  // 예산 칩
                  if (_budgetRange != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '${(_budgetRange!.start / 10000).toInt()}만원 - ${(_budgetRange!.end / 10000).toInt()}만원'
                        ),
                        onDeleted: () {
                          setState(() {
                            _budgetRange = null;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

          // 캠페인 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await userProvider.loadCampaigns();
              },
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCampaigns.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 64,
                                color: AppTheme.grey400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '캠페인이 없습니다.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCampaigns.length,
                          itemBuilder: (context, index) {
                            final campaign = filteredCampaigns[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CampaignCard(
                                campaign: campaign,
                                onTap: () {
                                  // TODO: 캠페인 상세 화면으로 이동
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${campaign.name} 상세 화면으로 이동'),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(CampaignStatus status) {
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
