import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/contract_model.dart';
import '../../providers/contract_provider.dart';
import '../../providers/auth_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String contractId;

  const PaymentScreen({
    Key? key,
    required this.contractId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractProvider>(context, listen: false)
          .loadContract(widget.contractId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<ContractProvider, AuthProvider>(
        builder: (context, contractProvider, authProvider, child) {
          if (contractProvider.isLoadingContract) {
            return const Center(child: CircularProgressIndicator());
          }

          final contract = contractProvider.currentContract;
          if (contract == null) {
            return const Center(
              child: Text('계약 정보를 불러올 수 없습니다'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 계약 정보
                _buildContractInfoCard(contract),

                const SizedBox(height: 16),

                // 결제 금액 정보
                _buildAmountCard(contract),

                const SizedBox(height: 16),

                // 결제 방법 선택
                _buildPaymentMethodCard(),

                const SizedBox(height: 16),

                // 약관 동의
                _buildTermsCard(),

                const SizedBox(height: 24),

                // 결제 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_agreeToTerms && !contractProvider.isProcessingPayment)
                        ? () => _processPayment(contract, contractProvider, authProvider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: contractProvider.isProcessingPayment
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '${_numberFormat.format(contract.amount)}원 결제하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (contractProvider.paymentError != null) ...[
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
                            contractProvider.paymentError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractInfoCard(Contract contract) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계약 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('캠페인', contract.campaignName),
            const SizedBox(height: 8),
            _buildInfoRow('인플루언서', contract.influencerName),
            const SizedBox(height: 8),
            _buildInfoRow('판매사', contract.sellerName),
            const SizedBox(height: 8),
            _buildInfoRow(
              '협업 기간',
              '${DateFormat('yyyy.MM.dd').format(contract.startDate)} - ${DateFormat('yyyy.MM.dd').format(contract.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(Contract contract) {
    final amount = contract.amount;
    final fee = (amount * 0.05).round(); // 5% 수수료
    final totalAmount = amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '결제 금액',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAmountRow('협업 금액', amount),
            const SizedBox(height: 4),
            _buildAmountRow('플랫폼 수수료 (5%)', fee, isNegative: true),
            const Divider(height: 24),
            _buildAmountRow('총 결제 금액', totalAmount, isBold: true, isTotal: true),
            const SizedBox(height: 8),
            Text(
              '* 인플루언서에게는 수수료를 제외한 ${_numberFormat.format(amount - fee)}원이 정산됩니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '결제 방법',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...PaymentMethod.values.map((method) {
              return RadioListTile<PaymentMethod>(
                title: Row(
                  children: [
                    Icon(_getPaymentMethodIcon(method)),
                    const SizedBox(width: 8),
                    Text(_getPaymentMethodName(method)),
                  ],
                ),
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '약관 동의',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('결제 서비스 약관에 동의합니다'),
              subtitle: TextButton(
                onPressed: () => _showTermsDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text('약관 보기'),
              ),
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
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

  Widget _buildAmountRow(String label, int amount, {bool isNegative = false, bool isBold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${_numberFormat.format(amount)}원',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue : (isNegative ? Colors.red : Colors.black),
          ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.kakaoPay:
        return Icons.chat_bubble;
      case PaymentMethod.naverPay:
        return Icons.shopping_cart;
      case PaymentMethod.payco:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return '신용/체크카드';
      case PaymentMethod.bankTransfer:
        return '계좌이체';
      case PaymentMethod.kakaoPay:
        return '카카오페이';
      case PaymentMethod.naverPay:
        return '네이버페이';
      case PaymentMethod.payco:
        return 'PAYCO';
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 서비스 약관'),
        content: const SingleChildScrollView(
          child: Text(
            '결제 서비스 약관\n\n'
            '1. 결제 서비스 이용 시 본 약관에 동의한 것으로 간주됩니다.\n'
            '2. 결제는 안전한 PG사를 통해 처리됩니다.\n'
            '3. 결제 완료 후 취소는 계약 조건에 따라 제한될 수 있습니다.\n'
            '4. 분쟁 발생 시 관련 법령에 따라 해결됩니다.\n'
            '5. 개인정보는 결제 처리 목적으로만 사용됩니다.\n\n'
            '자세한 내용은 홈페이지를 참고해주세요.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(
    Contract contract,
    ContractProvider contractProvider,
    AuthProvider authProvider,
  ) async {
    // 결제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 확인'),
        content: Text(
          '${_numberFormat.format(contract.amount)}원을 ${_getPaymentMethodName(_selectedMethod)}로 결제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('결제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 결제 처리
    final payment = await contractProvider.processPayment(
      contractId: contract.id,
      payerId: authProvider.user!.id,
      payeeName: authProvider.user!.name,
      amount: contract.amount,
      method: _selectedMethod,
    );

    if (mounted) {
      if (payment != null && payment.status == PaymentStatus.completed) {
        // 결제 성공
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('결제 완료'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('결제가 성공적으로 완료되었습니다.'),
                const SizedBox(height: 8),
                Text('거래번호: ${payment.transactionId}'),
                Text('결제금액: ${_numberFormat.format(payment.amount)}원'),
                Text('결제방법: ${payment.methodDisplayName}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  context.pop(); // 결제 화면 닫기
                },
                child: const Text('확인'),
              ),
              if (payment.receiptUrl != null)
                TextButton(
                  onPressed: () => _downloadReceipt(payment.receiptUrl!),
                  child: const Text('영수증'),
                ),
            ],
          ),
        );
      } else {
        // 결제 실패
        final failureReason = payment?.failureReason ?? '결제 처리 중 오류가 발생했습니다';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('결제 실패'),
              ],
            ),
            content: Text(failureReason),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _downloadReceipt(String receiptUrl) {
    // 영수증 다운로드 또는 웹뷰로 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('영수증 다운로드: $receiptUrl')),
    );
  }
}
