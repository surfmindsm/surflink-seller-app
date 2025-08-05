import 'package:flutter/material.dart';

// 계약서 상태
enum ContractStatus {
  draft, // 초안
  pending, // 대기중  
  signed, // 서명완료
  active, // 진행중
  completed, // 완료
  cancelled, // 취소
}

// 결제 상태
enum PaymentStatus {
  pending, // 결제 대기
  processing, // 결제 처리중
  completed, // 결제 완료
  failed, // 결제 실패
  refunded, // 환불
  cancelled, // 취소
}

// 결제 방법
enum PaymentMethod {
  creditCard, // 신용카드
  bankTransfer, // 계좌이체
  kakaoPay, // 카카오페이
  naverPay, // 네이버페이
  payco, // 페이코
}

// 계약서
class Contract {
  final String id;
  final String campaignId;
  final String sellerId;
  final String influencerId;
  final String campaignName;
  final String sellerName;
  final String influencerName;
  final int amount;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final List<String> deliverables;
  final ContractStatus status;
  final DateTime? signedAt;
  final String? sellerSignature;
  final String? influencerSignature;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalTerms;

  Contract({
    required this.id,
    required this.campaignId,
    required this.sellerId,
    required this.influencerId,
    required this.campaignName,
    required this.sellerName,
    required this.influencerName,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.deliverables,
    required this.status,
    this.signedAt,
    this.sellerSignature,
    this.influencerSignature,
    required this.createdAt,
    required this.updatedAt,
    this.additionalTerms,
  });

  String get statusDisplayName {
    switch (status) {
      case ContractStatus.draft:
        return '초안';
      case ContractStatus.pending:
        return '승인 대기';
      case ContractStatus.signed:
        return '서명 완료';
      case ContractStatus.active:
        return '진행중';
      case ContractStatus.completed:
        return '완료';
      case ContractStatus.cancelled:
        return '취소';
    }
  }

  Color get statusColor {
    switch (status) {
      case ContractStatus.draft:
        return Colors.grey;
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.signed:
        return Colors.blue;
      case ContractStatus.active:
        return Colors.green;
      case ContractStatus.completed:
        return Colors.purple;
      case ContractStatus.cancelled:
        return Colors.red;
    }
  }

  bool get canEdit => status == ContractStatus.draft;
  bool get canSign => status == ContractStatus.pending;
  bool get canCancel => [ContractStatus.draft, ContractStatus.pending].contains(status);

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
        id: json['id'],
        campaignId: json['campaign_id'],
        sellerId: json['seller_id'],
        influencerId: json['influencer_id'],
        campaignName: json['campaign_name'],
        sellerName: json['seller_name'],
        influencerName: json['influencer_name'],
        amount: json['amount'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        description: json['description'],
        deliverables: List<String>.from(json['deliverables']),
        status: ContractStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ContractStatus.draft,
        ),
        signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
        sellerSignature: json['seller_signature'],
        influencerSignature: json['influencer_signature'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        additionalTerms: json['additional_terms'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'campaign_id': campaignId,
        'seller_id': sellerId,
        'influencer_id': influencerId,
        'campaign_name': campaignName,
        'seller_name': sellerName,
        'influencer_name': influencerName,
        'amount': amount,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'description': description,
        'deliverables': deliverables,
        'status': status.name,
        'signed_at': signedAt?.toIso8601String(),
        'seller_signature': sellerSignature,
        'influencer_signature': influencerSignature,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'additional_terms': additionalTerms,
      };

  Contract copyWith({
    String? id,
    String? campaignId,
    String? sellerId,
    String? influencerId,
    String? campaignName,
    String? sellerName,
    String? influencerName,
    int? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    List<String>? deliverables,
    ContractStatus? status,
    DateTime? signedAt,
    String? sellerSignature,
    String? influencerSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalTerms,
  }) {
    return Contract(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      sellerId: sellerId ?? this.sellerId,
      influencerId: influencerId ?? this.influencerId,
      campaignName: campaignName ?? this.campaignName,
      sellerName: sellerName ?? this.sellerName,
      influencerName: influencerName ?? this.influencerName,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      deliverables: deliverables ?? this.deliverables,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
      sellerSignature: sellerSignature ?? this.sellerSignature,
      influencerSignature: influencerSignature ?? this.influencerSignature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalTerms: additionalTerms ?? this.additionalTerms,
    );
  }
}

// 결제 정보
class Payment {
  final String id;
  final String contractId;
  final String payerId;
  final String payeeName;
  final int amount;
  final int fee;
  final int actualAmount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? receiptUrl;
  final DateTime? paidAt;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.contractId,
    required this.payerId,
    required this.payeeName,
    required this.amount,
    required this.fee,
    required this.actualAmount,
    required this.method,
    required this.status,
    this.transactionId,
    this.receiptUrl,
    this.paidAt,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return '결제 대기';
      case PaymentStatus.processing:
        return '결제 중';
      case PaymentStatus.completed:
        return '결제 완료';
      case PaymentStatus.failed:
        return '결제 실패';
      case PaymentStatus.refunded:
        return '환불 완료';
      case PaymentStatus.cancelled:
        return '결제 취소';
    }
  }

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return '신용카드';
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

  Color get statusColor {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        contractId: json['contract_id'],
        payerId: json['payer_id'],
        payeeName: json['payee_name'],
        amount: json['amount'],
        fee: json['fee'],
        actualAmount: json['actual_amount'],
        method: PaymentMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => PaymentMethod.creditCard,
        ),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PaymentStatus.pending,
        ),
        transactionId: json['transaction_id'],
        receiptUrl: json['receipt_url'],
        paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
        failureReason: json['failure_reason'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_id': contractId,
        'payer_id': payerId,
        'payee_name': payeeName,
        'amount': amount,
        'fee': fee,
        'actual_amount': actualAmount,
        'method': method.name,
        'status': status.name,
        'transaction_id': transactionId,
        'receipt_url': receiptUrl,
        'paid_at': paidAt?.toIso8601String(),
        'failure_reason': failureReason,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
