import 'package:flutter/foundation.dart';
import '../models/contract_model.dart';
import '../models/user_model.dart';
import '../services/contract_service.dart';

class ContractProvider extends ChangeNotifier {
  final ContractService _contractService = ContractService();

  // 계약 목록
  List<Contract>? _contracts;
  bool _isLoadingContracts = false;
  String? _contractsError;

  // 현재 계약
  Contract? _currentContract;
  bool _isLoadingContract = false;
  String? _contractError;

  // 결제 목록
  List<Payment>? _payments;
  bool _isLoadingPayments = false;
  String? _paymentsError;

  // 정산 정보
  Map<String, dynamic>? _settlementInfo;
  bool _isLoadingSettlement = false;
  String? _settlementError;

  // 서명 처리
  bool _isSigning = false;
  String? _signError;

  // 결제 처리
  bool _isProcessingPayment = false;
  String? _paymentError;

  // Getters
  List<Contract>? get contracts => _contracts;
  bool get isLoadingContracts => _isLoadingContracts;
  String? get contractsError => _contractsError;

  Contract? get currentContract => _currentContract;
  bool get isLoadingContract => _isLoadingContract;
  String? get contractError => _contractError;

  List<Payment>? get payments => _payments;
  bool get isLoadingPayments => _isLoadingPayments;
  String? get paymentsError => _paymentsError;

  Map<String, dynamic>? get settlementInfo => _settlementInfo;
  bool get isLoadingSettlement => _isLoadingSettlement;
  String? get settlementError => _settlementError;

  bool get isSigning => _isSigning;
  String? get signError => _signError;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentError => _paymentError;

  // 계약 목록 조회
  Future<void> loadContracts(String userId) async {
    _isLoadingContracts = true;
    _contractsError = null;
    notifyListeners();

    try {
      _contracts = await _contractService.getContracts(userId);
    } catch (e) {
      _contractsError = e.toString();
    } finally {
      _isLoadingContracts = false;
      notifyListeners();
    }
  }

  // 특정 계약 조회
  Future<void> loadContract(String contractId) async {
    _isLoadingContract = true;
    _contractError = null;
    notifyListeners();

    try {
      _currentContract = await _contractService.getContract(contractId);
    } catch (e) {
      _contractError = e.toString();
    } finally {
      _isLoadingContract = false;
      notifyListeners();
    }
  }

  // 계약서 생성
  Future<Contract?> createContract({
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
    _isLoadingContract = true;
    _contractError = null;
    notifyListeners();

    try {
      final contract = await _contractService.createContract(
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
        additionalTerms: additionalTerms,
      );

      _currentContract = contract;
      
      // 계약 목록에 추가
      if (_contracts != null) {
        _contracts = [contract, ..._contracts!];
      }

      return contract;
    } catch (e) {
      _contractError = e.toString();
      return null;
    } finally {
      _isLoadingContract = false;
      notifyListeners();
    }
  }

  // 계약서 서명
  Future<bool> signContract(String contractId, String signature, UserType userType) async {
    _isSigning = true;
    _signError = null;
    notifyListeners();

    try {
      final updatedContract = await _contractService.signContract(contractId, signature, userType);
      
      _currentContract = updatedContract;
      
      // 계약 목록 업데이트
      if (_contracts != null) {
        final index = _contracts!.indexWhere((c) => c.id == contractId);
        if (index != -1) {
          _contracts![index] = updatedContract;
        }
      }

      return true;
    } catch (e) {
      _signError = e.toString();
      return false;
    } finally {
      _isSigning = false;
      notifyListeners();
    }
  }

  // 계약 상태 업데이트
  Future<bool> updateContractStatus(String contractId, ContractStatus status) async {
    try {
      final updatedContract = await _contractService.updateContractStatus(contractId, status);
      
      _currentContract = updatedContract;
      
      // 계약 목록 업데이트
      if (_contracts != null) {
        final index = _contracts!.indexWhere((c) => c.id == contractId);
        if (index != -1) {
          _contracts![index] = updatedContract;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 결제 목록 조회
  Future<void> loadPayments(String userId) async {
    _isLoadingPayments = true;
    _paymentsError = null;
    notifyListeners();

    try {
      _payments = await _contractService.getPayments(userId);
    } catch (e) {
      _paymentsError = e.toString();
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  // 결제 처리
  Future<Payment?> processPayment({
    required String contractId,
    required String payerId,
    required String payeeName,
    required int amount,
    required PaymentMethod method,
  }) async {
    _isProcessingPayment = true;
    _paymentError = null;
    notifyListeners();

    try {
      final payment = await _contractService.processPayment(
        contractId: contractId,
        payerId: payerId,
        payeeName: payeeName,
        amount: amount,
        method: method,
      );

      // 결제 목록에 추가
      if (_payments != null) {
        _payments = [payment, ..._payments!];
      }

      // 결제 성공 시 계약 상태 업데이트
      if (payment.status == PaymentStatus.completed) {
        await updateContractStatus(contractId, ContractStatus.active);
      }

      return payment;
    } catch (e) {
      _paymentError = e.toString();
      return null;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  // 환불 처리
  Future<bool> refundPayment(String paymentId, String reason) async {
    try {
      final refundedPayment = await _contractService.refundPayment(paymentId, reason);
      
      // 결제 목록 업데이트
      if (_payments != null) {
        final index = _payments!.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _payments![index] = refundedPayment;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 정산 정보 조회
  Future<void> loadSettlementInfo(String influencerId) async {
    _isLoadingSettlement = true;
    _settlementError = null;
    notifyListeners();

    try {
      _settlementInfo = await _contractService.getSettlementInfo(influencerId);
    } catch (e) {
      _settlementError = e.toString();
    } finally {
      _isLoadingSettlement = false;
      notifyListeners();
    }
  }

  // 출금 요청
  Future<bool> requestWithdrawal({
    required String influencerId,
    required int amount,
    required String bankAccount,
    required String accountHolder,
  }) async {
    try {
      final success = await _contractService.requestWithdrawal(
        influencerId: influencerId,
        amount: amount,
        bankAccount: bankAccount,
        accountHolder: accountHolder,
      );

      if (success) {
        // 정산 정보 새로고침
        await loadSettlementInfo(influencerId);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // 영수증/세금계산서 발급
  Future<String?> issueReceipt(String paymentId, String type) async {
    try {
      return await _contractService.issueReceipt(
        paymentId: paymentId,
        type: type,
      );
    } catch (e) {
      return null;
    }
  }

  // 상태별 계약 필터링
  List<Contract> getContractsByStatus(ContractStatus status) {
    if (_contracts == null) return [];
    return _contracts!.where((contract) => contract.status == status).toList();
  }

  // 사용자별 계약 필터링
  List<Contract> getContractsByUser(String userId, UserType userType) {
    if (_contracts == null) return [];
    
    if (userType == UserType.seller) {
      return _contracts!.where((contract) => contract.sellerId == userId).toList();
    } else {
      return _contracts!.where((contract) => contract.influencerId == userId).toList();
    }
  }

  // 데이터 초기화
  void clearData() {
    _contracts = null;
    _currentContract = null;
    _payments = null;
    _settlementInfo = null;
    _contractsError = null;
    _contractError = null;
    _paymentsError = null;
    _settlementError = null;
    _signError = null;
    _paymentError = null;
    notifyListeners();
  }
}
