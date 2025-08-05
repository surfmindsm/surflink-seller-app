import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/campaign_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class CampaignCreateScreen extends StatefulWidget {
  const CampaignCreateScreen({Key? key}) : super(key: key);

  @override
  State<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends State<CampaignCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _targetController = TextEditingController();

  List<String> _selectedCategories = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 30));
  bool _isLoading = false;

  final List<String> _categories = [
    '뷰티', '패션', '음식', '여행', '테크', '피트니스', '라이프스타일'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 등록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 캠페인명
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '캠페인명 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? '캠페인명을 입력하세요' : null,
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
              Text('카테고리 *', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
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

              // 예산
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '예산 (원) *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? '예산을 입력하세요' : null,
              ),
              const SizedBox(height: 16),

              // 기간 선택
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                      child: Text('시작일: ${_startDate.toString().split(' ')[0]}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                      child: Text('종료일: ${_endDate.toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 상세 설명
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '캠페인 상세 설명 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? '상세 설명을 입력하세요' : null,
              ),
              const SizedBox(height: 16),

              // 타겟 조건
              TextFormField(
                controller: _targetController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '타겟 인플루언서 조건',
                  hintText: '예: 팔로워 10만 이상, 뷰티 전문',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCampaign,
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('캠페인 등록', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createCampaign() async {
    if (!_formKey.currentState!.validate() || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 입력하세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final campaign = Campaign(
        id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
        sellerId: authProvider.user?.id ?? 'demo_seller',
        name: _nameController.text,
        categories: _selectedCategories,
        budget: int.parse(_budgetController.text),
        startDate: _startDate,
        endDate: _endDate,
        description: _descriptionController.text,
        targetConditions: _targetController.text,
        status: CampaignStatus.recruiting,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: 실제 API 연동
      await Future.delayed(Duration(seconds: 1)); // 시뮬레이션
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캠페인이 성공적으로 등록되었습니다!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
