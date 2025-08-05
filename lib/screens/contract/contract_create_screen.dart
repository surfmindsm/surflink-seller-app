import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/contract_provider.dart';
import '../../providers/auth_provider.dart';

class ContractCreateScreen extends StatefulWidget {
  final String campaignId;
  final String campaignName;
  final String influencerId;
  final String influencerName;

  const ContractCreateScreen({
    Key? key,
    required this.campaignId,
    required this.campaignName,
    required this.influencerId,
    required this.influencerName,
  }) : super(key: key);

  @override
  State<ContractCreateScreen> createState() => _ContractCreateScreenState();
}

class _ContractCreateScreenState extends State<ContractCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _deliverables = [''];
  Map<String, dynamic> _additionalTerms = {
    'revision_count': 2,
    'usage_rights': '6개월',
    'exclusivity': false,
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계약서 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<ContractProvider, AuthProvider>(
        builder: (context, contractProvider, authProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기본 정보
                  _buildSectionCard(
                    title: '기본 정보',
                    children: [
                      _buildInfoRow('캠페인명', widget.campaignName),
                      const SizedBox(height: 8),
                      _buildInfoRow('인플루언서', widget.influencerName),
                      const SizedBox(height: 8),
                      _buildInfoRow('판매사', authProvider.user?.name ?? ''),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 협업 조건
                  _buildSectionCard(
                    title: '협업 조건',
                    children: [
                      // 협업 금액
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: '협업 금액 (원)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          hintText: '예: 500000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '협업 금액을 입력해주세요';
                          }
                          final amount = int.tryParse(value.replaceAll(',', ''));
                          if (amount == null || amount <= 0) {
                            return '올바른 금액을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 협업 기간
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '시작일',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _startDate != null
                                      ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                                      : '날짜 선택',
                                  style: TextStyle(
                                    color: _startDate != null ? null : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '종료일',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _endDate != null
                                      ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                                      : '날짜 선택',
                                  style: TextStyle(
                                    color: _endDate != null ? null : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 협업 내용
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '협업 내용',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                          hintText: '협업에 대한 상세 설명을 입력해주세요',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '협업 내용을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 제공 항목
                  _buildSectionCard(
                    title: '제공 항목',
                    children: [
                      ..._buildDeliverableFields(),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addDeliverable,
                        icon: const Icon(Icons.add),
                        label: const Text('항목 추가'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 추가 조건
                  _buildSectionCard(
                    title: '추가 조건',
                    children: [
                      // 수정 횟수
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '수정 가능 횟수',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          DropdownButton<int>(
                            value: _additionalTerms['revision_count'],
                            items: List.generate(6, (index) => index)
                                .map((count) => DropdownMenuItem(
                                      value: count,
                                      child: Text(count == 0 ? '무제한' : '$count회'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _additionalTerms['revision_count'] = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 사용권 기간
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '사용권 기간',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          DropdownButton<String>(
                            value: _additionalTerms['usage_rights'],
                            items: ['3개월', '6개월', '1년', '무제한']
                                .map((period) => DropdownMenuItem(
                                      value: period,
                                      child: Text(period),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _additionalTerms['usage_rights'] = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 독점 계약
                      CheckboxListTile(
                        title: const Text('독점 계약'),
                        subtitle: const Text('계약 기간 동안 동종 업계 협업 제한'),
                        value: _additionalTerms['exclusivity'] ?? false,
                        onChanged: (value) {
                          setState(() {
                            _additionalTerms['exclusivity'] = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: contractProvider.isLoadingContract
                          ? null
                          : () => _createContract(contractProvider, authProvider),
                      child: contractProvider.isLoadingContract
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('계약서 생성'),
                    ),
                  ),

                  if (contractProvider.contractError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              contractProvider.contractError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDeliverableFields() {
    return _deliverables.asMap().entries.map((entry) {
      final index = entry.key;
      final deliverable = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: deliverable,
                decoration: InputDecoration(
                  labelText: '제공 항목 ${index + 1}',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: const OutlineInputBorder(),
                  hintText: '예: 인스타그램 피드 포스팅 3회',
                ),
                onChanged: (value) {
                  _deliverables[index] = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제공 항목을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            if (_deliverables.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeDeliverable(index),
                icon: const Icon(Icons.remove_circle, color: Colors.red),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  void _addDeliverable() {
    setState(() {
      _deliverables.add('');
    });
  }

  void _removeDeliverable(int index) {
    if (_deliverables.length > 1) {
      setState(() {
        _deliverables.removeAt(index);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate 
        ? DateTime.now() 
        : _startDate ?? DateTime.now();
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // 시작일이 변경되면 종료일 재검증
          if (_endDate != null && _endDate!.isBefore(selectedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _createContract(ContractProvider contractProvider, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('협업 기간을 선택해주세요')),
      );
      return;
    }

    final amount = int.parse(_amountController.text.replaceAll(',', ''));
    final cleanDeliverables = _deliverables
        .where((d) => d.isNotEmpty)
        .toList();

    if (cleanDeliverables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개의 제공 항목을 입력해주세요')),
      );
      return;
    }

    final contract = await contractProvider.createContract(
      campaignId: widget.campaignId,
      sellerId: authProvider.user!.id,
      influencerId: widget.influencerId,
      campaignName: widget.campaignName,
      sellerName: authProvider.user!.name,
      influencerName: widget.influencerName,
      amount: amount,
      startDate: _startDate!,
      endDate: _endDate!,
      description: _descriptionController.text,
      deliverables: cleanDeliverables,
      additionalTerms: _additionalTerms,
    );

    if (contract != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계약서가 생성되었습니다')),
        );
        context.pop();
      }
    }
  }
}
