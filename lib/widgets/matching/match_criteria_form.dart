import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/match_model.dart';
import '../../services/auto_match_service.dart';

class MatchCriteriaForm extends StatefulWidget {
  final Function(MatchCriteria) onCriteriaChanged;
  final Function(MatchCriteria) onMatchRequested;

  const MatchCriteriaForm({
    Key? key,
    required this.onCriteriaChanged,
    required this.onMatchRequested,
  }) : super(key: key);

  @override
  State<MatchCriteriaForm> createState() => _MatchCriteriaFormState();
}

class _MatchCriteriaFormState extends State<MatchCriteriaForm> {
  final AutoMatchService _matchService = AutoMatchService();
  
  // 폼 상태
  List<String> _selectedCategories = [];
  String? _selectedRegion;
  bool _isVerifiedOnly = false;
  
  // 예산 범위
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  
  // 팔로워 범위
  final TextEditingController _minFollowersController = TextEditingController();
  final TextEditingController _maxFollowersController = TextEditingController();

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _minFollowersController.dispose();
    _maxFollowersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '매칭 조건 설정',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 카테고리 선택
            _buildCategorySection(),
            const SizedBox(height: 24),
            
            // 예산 범위
            _buildBudgetSection(),
            const SizedBox(height: 24),
            
            // 지역 선택
            _buildRegionSection(),
            const SizedBox(height: 24),
            
            // 팔로워 범위
            _buildFollowersSection(),
            const SizedBox(height: 24),
            
            // 인증 여부
            _buildVerificationSection(),
            const SizedBox(height: 32),
            
            // 매칭 시작 버튼
            _buildMatchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '카테고리 *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '원하는 인플루언서의 전문 분야를 선택하세요. (최대 3개)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _matchService.getAvailableCategories().map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_selectedCategories.length >= 3 && !isSelected) 
                ? null 
                : (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                      _updateCriteria();
                    });
                  },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
        if (_selectedCategories.length >= 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '최대 3개까지 선택 가능합니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '예산 범위',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '협업 예산 범위를 입력하세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minBudgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '최소 예산',
                  hintText: '100000',
                  suffixText: '원',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateCriteria(),
              ),
            ),
            const SizedBox(width: 16),
            const Text('~', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxBudgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '최대 예산',
                  hintText: '1000000',
                  suffixText: '원',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateCriteria(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '활동 지역',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '인플루언서의 주요 활동 지역을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedRegion,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '지역을 선택하세요',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('전체 지역'),
            ),
            ..._matchService.getAvailableRegions().map((region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRegion = value;
              _updateCriteria();
            });
          },
        ),
      ],
    );
  }

  Widget _buildFollowersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '팔로워 범위',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '원하는 팔로워 수 범위를 입력하세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minFollowersController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '최소 팔로워',
                  hintText: '10000',
                  suffixText: '명',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateCriteria(),
              ),
            ),
            const SizedBox(width: 16),
            const Text('~', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxFollowersController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '최대 팔로워',
                  hintText: '1000000',
                  suffixText: '명',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateCriteria(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '인증 여부',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('프로필 인증된 인플루언서만'),
          subtitle: Text(
            '신뢰도가 높은 인증된 인플루언서만 매칭됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          value: _isVerifiedOnly,
          onChanged: (value) {
            setState(() {
              _isVerifiedOnly = value;
              _updateCriteria();
            });
          },
          activeColor: Theme.of(context).primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildMatchButton() {
    final isValid = _selectedCategories.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isValid ? _performMatch : null,
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          '자동매칭 시작',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _updateCriteria() {
    final criteria = _buildCurrentCriteria();
    widget.onCriteriaChanged(criteria);
  }

  void _performMatch() {
    final criteria = _buildCurrentCriteria();
    widget.onMatchRequested(criteria);
  }

  MatchCriteria _buildCurrentCriteria() {
    return MatchCriteria(
      categories: _selectedCategories,
      minBudget: _minBudgetController.text.isNotEmpty 
        ? int.tryParse(_minBudgetController.text) 
        : null,
      maxBudget: _maxBudgetController.text.isNotEmpty 
        ? int.tryParse(_maxBudgetController.text) 
        : null,
      region: _selectedRegion,
      minFollowers: _minFollowersController.text.isNotEmpty 
        ? int.tryParse(_minFollowersController.text) 
        : null,
      maxFollowers: _maxFollowersController.text.isNotEmpty 
        ? int.tryParse(_maxFollowersController.text) 
        : null,
      isVerified: _isVerifiedOnly ? true : null,
    );
  }
}
