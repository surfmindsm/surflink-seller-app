import '../models/contract_model.dart';
import '../models/user_model.dart';

class ContractService {
  // 계약 목록 조회
  Future<List<Contract>> getContracts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      Contract(
        id: 'contract_1',
        campaignId: 'campaign_1',
        sellerId: 'seller_1',
        influencerId: 'influencer_1',
        campaignName: 'ABC 브랜드 신제품 런칭 캠페인',
        sellerName: 'ABC Company',
        influencerName: '뷰티인플루언서',
        amount: 500000,
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 10)),
        description: '신제품 언박싱 및 체험 영상 제작',
        deliverables: [
          '인스타그램 피드 포스팅 3회',
          '스토리 5회 이상',
          '유튜브 리뷰 영상 1개',
        ],
        status: ContractStatus.signed,
        signedAt: now.subtract(const Duration(hours: 2)),
        sellerSignature: 'seller_signature_data',
        influencerSignature: 'influencer_signature_data',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        additionalTerms: {
          'revision_count': 2,
          'usage_rights': '6개월',
          'exclusivity': false,
        },
      ),
      Contract(
        id: 'contract_2',
        campaignId: 'campaign_2',
        sellerId: 'seller_2',
        influencerId: 'influencer_2',
        campaignName: 'XYZ 패션 브랜드 협업',
        sellerName: 'XYZ Fashion',
        influencerName: '패션스타일리스트',
        amount: 800000,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 14)),
        description: '여름 신상 룩북 촬영 및 홍보',
        deliverables: [
          '인스타그램 피드 포스팅 5회',
          '릴스 제작 3개',
          '협찬 상품 착용 사진 10장',
        ],
        status: ContractStatus.pending,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      Contract(
        id: 'contract_3',
        campaignId: 'campaign_3',
        sellerId: 'seller_3',
        influencerId: 'influencer_3',
        campaignName: '건강식품 체험단 모집',
        sellerName: 'Health Plus',
        influencerName: '헬스인플루언서',
        amount: 300000,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 2)),
        description: '건강식품 4주 체험 후기 작성',
        deliverables: [
          '매주 체험 후기 포스팅',
          '최종 리뷰 영상 제작',
        ],
        status: ContractStatus.active,
        signedAt: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Contract(
        id: 'contract_4',
        campaignId: 'campaign_4',
        sellerId: 'seller_4',
        influencerId: 'influencer_4',
        campaignName: '카페 체인 매장 홍보',
        sellerName: '맛있는 카페',
        influencerName: '맛집탐험가',
        amount: 150000,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        description: '신메뉴 체험 및 리뷰',
        deliverables: [
          '메뉴 사진 업로드',
          '맛집 후기 작성',
          '인스타그램 스토리 3회',
        ],
        status: ContractStatus.draft,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      Contract(
        id: 'contract_5',
        campaignId: 'campaign_5',
        sellerId: 'seller_5',
        influencerId: 'influencer_5',
        campaignName: '게임 신작 체험단',
        sellerName: 'Game Studio',
        influencerName: '게임 리뷰어',
        amount: 600000,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 6)),
        description: '모바일 게임 체험 및 리뷰',
        deliverables: [
          '게임플레이 영상 10분',
          '리뷰 블로그 포스팅',
          '에스네이청 3개 제작',
        ],
        status: ContractStatus.active,
        signedAt: now.subtract(const Duration(days: 2)),
        sellerSignature: 'seller_sig_5',
        influencerSignature: 'influencer_sig_5',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        additionalTerms: {
          'revision_count': 1,
          'usage_rights': '1년',
          'exclusivity': true,
        },
      ),
      Contract(
        id: 'contract_6',
        campaignId: 'campaign_6',
        sellerId: 'seller_6',
        influencerId: 'influencer_6',
        campaignName: '육아 용품 협찬',
        sellerName: 'Baby Care',
        influencerName: '육아인플루언서',
        amount: 400000,
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 12)),
        description: '신생아 용품 사용법 안내',
        deliverables: [
          '사용법 안내 영상',
          '전후 비교 사진',
          '육아 팁 콘텐츠 5개',
        ],
        status: ContractStatus.completed,
        signedAt: now.subtract(const Duration(days: 15)),
        sellerSignature: 'seller_sig_6',
        influencerSignature: 'influencer_sig_6',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
        additionalTerms: {
          'revision_count': 3,
          'usage_rights': '6개월',
          'exclusivity': false,
        },
      ),
    ];
  }

  // 특정 계약 조회
  Future<Contract?> getContract(String contractId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final contracts = await getContracts('user_id');
    return contracts.firstWhere(
      (contract) => contract.id == contractId,
      orElse: () => throw Exception('계약을 찾을 수 없습니다'),
    );
  }

  // 계약서 생성
  Future<Contract> createContract({
    required String campaignId,
    required String sellerId,
    required String influencerId,
    required String campaignName,
    required String sellerName,
    required String influencerName,
    required int amount,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    required List<String> deliverables,
    Map<String, dynamic>? additionalTerms,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final now = DateTime.now();
    return Contract(
      id: 'contract_${now.millisecondsSinceEpoch}',
      campaignId: campaignId,
      sellerId: sellerId,
      influencerId: influencerId,
      campaignName: campaignName,
      sellerName: sellerName,
      influencerName: influencerName,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      description: description,
      deliverables: deliverables,
      status: ContractStatus.draft,
      createdAt: now,
      updatedAt: now,
      additionalTerms: additionalTerms,
    );
  }

  // 계약서 서명
  Future<Contract> signContract(String contractId, String signature, UserType userType) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final contract = await getContract(contractId);
    if (contract == null) {
      throw Exception('계약을 찾을 수 없습니다');
    }

    final now = DateTime.now();
    if (userType == UserType.seller) {
      return contract.copyWith(
        sellerSignature: signature,
        status: contract.influencerSignature != null ? ContractStatus.signed : ContractStatus.pending,
        signedAt: contract.influencerSignature != null ? now : null,
        updatedAt: now,
      );
    } else {
      return contract.copyWith(
        influencerSignature: signature,
        status: contract.sellerSignature != null ? ContractStatus.signed : ContractStatus.pending,
        signedAt: contract.sellerSignature != null ? now : null,
        updatedAt: now,
      );
    }
  }

  // 계약 상태 업데이트
  Future<Contract> updateContractStatus(String contractId, ContractStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final contract = await getContract(contractId);
    if (contract == null) {
      throw Exception('계약을 찾을 수 없습니다');
    }

    return contract.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  // 결제 정보 조회
  Future<List<Payment>> getPayments(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    return [
      Payment(
        id: 'payment_1',
        contractId: 'contract_1',
        payerId: 'seller_1',
        payeeName: 'ABC Company',
        amount: 500000,
        fee: 25000,
        actualAmount: 475000,
        method: PaymentMethod.creditCard,
        status: PaymentStatus.completed,
        transactionId: 'TXN_ABC123456',
        receiptUrl: 'https://example.com/receipt/1',
        paidAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Payment(
        id: 'payment_2',
        contractId: 'contract_2',
        payerId: 'seller_2',
        payeeName: 'XYZ Fashion',
        amount: 800000,
        fee: 40000,
        actualAmount: 760000,
        method: PaymentMethod.kakaoPay,
        status: PaymentStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  // 결제 처리
  Future<Payment> processPayment({
    required String contractId,
    required String payerId,
    required String payeeName,
    required int amount,
    required PaymentMethod method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock payment processing - 실제로는 PG사 연동
    final isSuccess = DateTime.now().millisecondsSinceEpoch % 2 == 0; // 50% 성공률

    final now = DateTime.now();
    final fee = (amount * 0.05).round(); // 5% 수수료
    
    return Payment(
      id: 'payment_${now.millisecondsSinceEpoch}',
      contractId: contractId,
      payerId: payerId,
      payeeName: payeeName,
      amount: amount,
      fee: fee,
      actualAmount: amount - fee,
      method: method,
      status: isSuccess ? PaymentStatus.completed : PaymentStatus.failed,
      transactionId: isSuccess ? 'TXN_${now.millisecondsSinceEpoch}' : null,
      receiptUrl: isSuccess ? 'https://example.com/receipt/${now.millisecondsSinceEpoch}' : null,
      paidAt: isSuccess ? now : null,
      failureReason: isSuccess ? null : '결제 승인이 거절되었습니다',
      createdAt: now,
      updatedAt: now,
    );
  }

  // 환불 처리
  Future<Payment> refundPayment(String paymentId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock refund processing
    final payments = await getPayments('user_id');
    final payment = payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('결제 정보를 찾을 수 없습니다'),
    );

    return Payment(
      id: payment.id,
      contractId: payment.contractId,
      payerId: payment.payerId,
      payeeName: payment.payeeName,
      amount: payment.amount,
      fee: payment.fee,
      actualAmount: payment.actualAmount,
      method: payment.method,
      status: PaymentStatus.refunded,
      transactionId: payment.transactionId,
      receiptUrl: payment.receiptUrl,
      paidAt: payment.paidAt,
      failureReason: reason,
      createdAt: payment.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // 정산 정보 조회
  Future<Map<String, dynamic>> getSettlementInfo(String influencerId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'total_earnings': 2350000,
      'pending_amount': 800000,
      'available_amount': 1550000,
      'withdrawn_amount': 1200000,
      'monthly_earnings': [
        {'month': '2024-01', 'amount': 450000},
        {'month': '2024-02', 'amount': 380000},
        {'month': '2024-03', 'amount': 520000},
        {'month': '2024-04', 'amount': 600000},
        {'month': '2024-05', 'amount': 400000},
      ],
      'recent_transactions': [
        {
          'id': 'settlement_1',
          'type': 'earning',
          'amount': 475000,
          'description': 'ABC 브랜드 캠페인 정산',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'settlement_2',
          'type': 'withdrawal',
          'amount': -200000,
          'description': '출금 요청',
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ],
    };
  }

  // 출금 요청
  Future<bool> requestWithdrawal({
    required String influencerId,
    required int amount,
    required String bankAccount,
    required String accountHolder,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock withdrawal request
    return true; // 성공
  }

  // 세금계산서/영수증 발급
  Future<String> issueReceipt({
    required String paymentId,
    required String type, // 'receipt' or 'tax_invoice'
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://example.com/$type/$timestamp.pdf';
  }
}
