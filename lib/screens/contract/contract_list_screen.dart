import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/contract_model.dart';
import '../../providers/contract_provider.dart';
import '../../providers/auth_provider.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({Key? key}) : super(key: key);

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<ContractProvider>(context, listen: false)
            .loadContracts(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계약 관리'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '초안'),
            Tab(text: '대기중'),
            Tab(text: '서명완료'),
            Tab(text: '진행중'),
            Tab(text: '완료'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshContracts(),
          ),
        ],
      ),
      body: Consumer2<ContractProvider, AuthProvider>(
        builder: (context, contractProvider, authProvider, child) {
          if (contractProvider.isLoadingContracts) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contractProvider.contractsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    contractProvider.contractsError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshContracts(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final contracts = contractProvider.contracts ?? [];
          
          if (contracts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '등록된 계약이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildContractList(contracts),
              _buildContractList(_filterContractsByStatus(contracts, ContractStatus.draft)),
              _buildContractList(_filterContractsByStatus(contracts, ContractStatus.pending)),
              _buildContractList(_filterContractsByStatus(contracts, ContractStatus.signed)),
              _buildContractList(_filterContractsByStatus(contracts, ContractStatus.active)),
              _buildContractList(_filterContractsByStatus(contracts, ContractStatus.completed)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContractList(List<Contract> contracts) {
    if (contracts.isEmpty) {
      return const Center(
        child: Text(
          '해당하는 계약이 없습니다',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshContracts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return _buildContractCard(contract);
        },
      ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    final isInfluencer = Provider.of<AuthProvider>(context, listen: false).user?.type.name == 'influencer';
    final partnerName = isInfluencer ? contract.sellerName : contract.influencerName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/contract/${contract.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Expanded(
                    child: Text(
                      contract.campaignName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: contract.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: contract.statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      contract.statusDisplayName,
                      style: TextStyle(
                        color: contract.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 파트너 정보
              Row(
                children: [
                  Icon(
                    isInfluencer ? Icons.store : Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    partnerName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 금액 및 기간
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_numberFormat.format(contract.amount)}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MM/dd').format(contract.startDate)} - ${DateFormat('MM/dd').format(contract.endDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 제공 항목 (최대 2개만 표시)
              if (contract.deliverables.isNotEmpty) ...[
                Text(
                  '제공 항목',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                ...contract.deliverables.take(2).map((deliverable) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            deliverable,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (contract.deliverables.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '외 ${contract.deliverables.length - 2}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 8),

              // 하단 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생성일: ${DateFormat('yyyy.MM.dd').format(contract.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Row(
                    children: [
                      if (contract.canEdit)
                        TextButton.icon(
                          onPressed: () => _editContract(contract),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('수정'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (contract.canSign)
                        TextButton.icon(
                          onPressed: () => _signContract(contract),
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: const Text('서명'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (contract.canCancel)
                        TextButton.icon(
                          onPressed: () => _cancelContract(contract),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('취소'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Contract> _filterContractsByStatus(List<Contract> contracts, ContractStatus status) {
    return contracts.where((contract) => contract.status == status).toList();
  }

  Future<void> _refreshContracts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await Provider.of<ContractProvider>(context, listen: false)
          .loadContracts(authProvider.user!.id);
    }
  }

  void _editContract(Contract contract) {
    // 계약서 수정 화면으로 이동
    context.push('/contract/${contract.id}/edit');
  }

  void _signContract(Contract contract) {
    // 계약서 서명 화면으로 이동
    context.push('/contract/${contract.id}/sign');
  }

  Future<void> _cancelContract(Contract contract) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계약 취소'),
        content: const Text('정말로 이 계약을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final contractProvider = Provider.of<ContractProvider>(context, listen: false);
      final success = await contractProvider.updateContractStatus(
        contract.id,
        ContractStatus.cancelled,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계약이 취소되었습니다')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('계약 취소에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
