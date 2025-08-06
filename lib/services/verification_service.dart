import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/verification_model.dart';
import '../models/file_upload_model.dart';

/// 인증 서비스 (목업 구현)
class VerificationService {
  static const Duration _processingDelay = Duration(seconds: 2);
  
  /// 사용자 인증 상태 조회
  Future<UserVerificationStatus> getUserVerificationStatus(String userId) async {
    await Future.delayed(_processingDelay);
    
    // 목업 데이터 생성
    Map<VerificationType, VerificationInfo> verifications = {};
    
    // 기본 인증 상태 설정
    verifications[VerificationType.phone] = VerificationInfo(
      type: VerificationType.phone,
      status: VerificationStatus.approved,
      submittedAt: DateTime.now().subtract(const Duration(days: 30)),
      approvedAt: DateTime.now().subtract(const Duration(days: 29)),
      metadata: {'phone': '010-****-****'},
    );
    
    verifications[VerificationType.email] = VerificationInfo(
      type: VerificationType.email,
      status: VerificationStatus.approved,
      submittedAt: DateTime.now().subtract(const Duration(days: 25)),
      approvedAt: DateTime.now().subtract(const Duration(days: 24)),
      metadata: {'email': 'user@example.com'},
    );
    
    verifications[VerificationType.identity] = VerificationInfo(
      type: VerificationType.identity,
      status: VerificationStatus.notStarted,
    );
    
    verifications[VerificationType.business] = VerificationInfo(
      type: VerificationType.business,
      status: VerificationStatus.notStarted,
    );
    
    verifications[VerificationType.sns] = VerificationInfo(
      type: VerificationType.sns,
      status: VerificationStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {'instagram': '@test_account', 'followers': 5000},
    );
    
    verifications[VerificationType.portfolio] = VerificationInfo(
      type: VerificationType.portfolio,
      status: VerificationStatus.notStarted,
    );
    
    return UserVerificationStatus(
      verifications: verifications,
      verificationScore: 35, // 자동 계산됨
      verificationLevel: '브론즈', // 자동 계산됨
    );
  }
  
  /// 인증 요청 제출
  Future<VerificationInfo> submitVerificationRequest(
    String userId,
    VerificationRequest request,
  ) async {
    await Future.delayed(_processingDelay);
    
    try {
      // 목업: 성공적으로 제출됨
      return VerificationInfo(
        type: request.type,
        status: VerificationStatus.pending,
        submittedAt: DateTime.now(),
        documents: request.documents,
        metadata: request.data,
      );
    } catch (e) {
      throw Exception('인증 요청 제출에 실패했습니다: ${e.toString()}');
    }
  }
  
  /// 실명 인증 요청
  Future<VerificationInfo> requestIdentityVerification(
    String userId, {
    required String name,
    required String birthDate,
    required String gender,
    required List<UploadedFile> documents,
  }) async {
    final request = VerificationRequest(
      type: VerificationType.identity,
      data: {
        'name': name,
        'birth_date': birthDate,
        'gender': gender,
      },
      documents: documents,
      notes: '실명 인증을 위한 신분증 사본입니다.',
    );
    
    return await submitVerificationRequest(userId, request);
  }
  
  /// 사업자 인증 요청
  Future<VerificationInfo> requestBusinessVerification(
    String userId, {
    required String businessNumber,
    required String businessName,
    required String ownerName,
    required List<UploadedFile> documents,
  }) async {
    final request = VerificationRequest(
      type: VerificationType.business,
      data: {
        'business_number': businessNumber,
        'business_name': businessName,
        'owner_name': ownerName,
      },
      documents: documents,
      notes: '사업자등록증 인증을 위한 서류입니다.',
    );
    
    return await submitVerificationRequest(userId, request);
  }
  
  /// SNS 계정 인증 요청
  Future<VerificationInfo> requestSnsVerification(
    String userId, {
    required String platform,
    required String account,
    required int followersCount,
  }) async {
    // 목업: 실제로는 SNS API 연동
    await Future.delayed(const Duration(seconds: 3));
    
    // 팔로워 수 검증 시뮬레이션
    final isValid = await _validateSnsAccount(platform, account, followersCount);
    
    if (!isValid) {
      return VerificationInfo(
        type: VerificationType.sns,
        status: VerificationStatus.rejected,
        submittedAt: DateTime.now(),
        rejectReason: 'SNS 계정 정보가 일치하지 않습니다.',
        metadata: {
          'platform': platform,
          'account': account,
          'followers_count': followersCount,
        },
      );
    }
    
    return VerificationInfo(
      type: VerificationType.sns,
      status: VerificationStatus.approved,
      submittedAt: DateTime.now(),
      approvedAt: DateTime.now(),
      metadata: {
        'platform': platform,
        'account': account,
        'followers_count': followersCount,
        'verified_followers': followersCount,
      },
    );
  }
  
  /// 포트폴리오 인증 요청
  Future<VerificationInfo> requestPortfolioVerification(
    String userId, {
    required List<UploadedFile> portfolioFiles,
    required String description,
  }) async {
    final request = VerificationRequest(
      type: VerificationType.portfolio,
      data: {
        'description': description,
        'file_count': portfolioFiles.length,
      },
      documents: portfolioFiles,
      notes: '포트폴리오 인증을 위한 작업물입니다.',
    );
    
    return await submitVerificationRequest(userId, request);
  }
  
  /// 휴대폰 인증 요청
  Future<String> requestPhoneVerification(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 목업: 인증번호 생성
    final code = _generateVerificationCode();
    
    debugPrint('휴대폰 인증번호 전송: $phoneNumber -> $code');
    
    return code;
  }
  
  /// 휴대폰 인증 확인
  Future<VerificationInfo> verifyPhoneCode(
    String userId,
    String phoneNumber,
    String code,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 목업: 인증번호 검증
    final isValid = code == '123456' || code.length == 6;
    
    if (!isValid) {
      throw Exception('인증번호가 올바르지 않습니다.');
    }
    
    return VerificationInfo(
      type: VerificationType.phone,
      status: VerificationStatus.approved,
      submittedAt: DateTime.now(),
      approvedAt: DateTime.now(),
      metadata: {'phone': phoneNumber},
    );
  }
  
  /// 이메일 인증 요청
  Future<bool> requestEmailVerification(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    
    debugPrint('이메일 인증 링크 전송: $email');
    
    return true;
  }
  
  /// 이메일 인증 확인
  Future<VerificationInfo> verifyEmailToken(
    String userId,
    String email,
    String token,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 목업: 토큰 검증
    final isValid = token.isNotEmpty;
    
    if (!isValid) {
      throw Exception('인증 토큰이 올바르지 않습니다.');
    }
    
    return VerificationInfo(
      type: VerificationType.email,
      status: VerificationStatus.approved,
      submittedAt: DateTime.now(),
      approvedAt: DateTime.now(),
      metadata: {'email': email},
    );
  }
  
  /// 인증 상태 업데이트 (관리자용)
  Future<VerificationInfo> updateVerificationStatus(
    String userId,
    VerificationType type,
    VerificationStatus newStatus, {
    String? rejectReason,
  }) async {
    await Future.delayed(_processingDelay);
    
    // 목업: 관리자가 인증 상태를 변경
    final now = DateTime.now();
    
    return VerificationInfo(
      type: type,
      status: newStatus,
      submittedAt: now,
      approvedAt: newStatus == VerificationStatus.approved ? now : null,
      rejectReason: newStatus == VerificationStatus.rejected ? rejectReason : null,
    );
  }
  
  /// 인증 문서 업로드
  Future<List<UploadedFile>> uploadVerificationDocuments(
    String userId,
    VerificationType type,
    List<UploadedFile> files,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // 목업: 파일 업로드 시뮬레이션
    return files.map((file) => file.copyWith(
      serverUrl: 'https://api.sellerseller.co.kr/verification/${type.name}/${file.id}',
      status: FileUploadStatus.uploaded,
      uploadedAt: DateTime.now(),
    )).toList();
  }
  
  /// SNS 계정 유효성 검증 (목업)
  Future<bool> _validateSnsAccount(String platform, String account, int followersCount) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 목업: 90% 확률로 성공
    final random = Random();
    return random.nextInt(10) < 9;
  }
  
  /// 인증번호 생성
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  /// 인증 가능한 타입 조회
  List<VerificationType> getAvailableVerificationTypes(String userType) {
    if (userType == 'seller') {
      return [
        VerificationType.phone,
        VerificationType.email,
        VerificationType.business,
        VerificationType.identity,
        VerificationType.address,
      ];
    } else {
      return [
        VerificationType.phone,
        VerificationType.email,
        VerificationType.identity,
        VerificationType.sns,
        VerificationType.portfolio,
        VerificationType.followers,
      ];
    }
  }
  
  /// 인증 요구사항 조회
  Map<String, dynamic> getVerificationRequirements(VerificationType type) {
    switch (type) {
      case VerificationType.identity:
        return {
          'title': '실명 인증',
          'description': '신분증 사본을 업로드하여 실명을 인증하세요.',
          'documents': ['주민등록증', '여권', '운전면허증'],
          'processing_time': '1-2일',
          'benefits': ['신뢰도 상승', '우선 매칭', '프리미엄 기능 이용'],
        };
        
      case VerificationType.business:
        return {
          'title': '사업자 인증',
          'description': '사업자등록증을 업로드하여 사업자 정보를 인증하세요.',
          'documents': ['사업자등록증'],
          'processing_time': '1-3일',
          'benefits': ['기업 회원 인증', '세금계산서 발행', '우선 노출'],
        };
        
      case VerificationType.sns:
        return {
          'title': 'SNS 인증',
          'description': 'SNS 계정을 연동하여 팔로워 수와 계정을 인증하세요.',
          'documents': [],
          'processing_time': '즉시',
          'benefits': ['팔로워 수 표시', '인플루언서 인증', '매칭 정확도 향상'],
        };
        
      case VerificationType.portfolio:
        return {
          'title': '포트폴리오 인증',
          'description': '작업물을 업로드하여 전문성을 인증하세요.',
          'documents': ['작업물 이미지', '동영상', '결과물'],
          'processing_time': '2-5일',
          'benefits': ['전문성 인증', '우선 매칭', '높은 단가 책정'],
        };
        
      default:
        return {
          'title': '인증',
          'description': '인증을 진행하세요.',
          'documents': [],
          'processing_time': '1-3일',
          'benefits': ['신뢰도 상승'],
        };
    }
  }
}
