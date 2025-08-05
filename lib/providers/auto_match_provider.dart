import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/auto_match_service.dart';

class AutoMatchProvider extends ChangeNotifier {
  final AutoMatchService _matchService = AutoMatchService();
  
  // 상태 관리
  bool _isLoading = false;
  String? _error;
  AutoMatchResponse? _lastMatchResult;
  MatchCriteria? _currentCriteria;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AutoMatchResponse? get lastMatchResult => _lastMatchResult;
  MatchCriteria? get currentCriteria => _currentCriteria;
  List<MatchResult> get matches => _lastMatchResult?.matches ?? [];

  // 사용 가능한 옵션들
  List<String> get availableCategories => _matchService.getAvailableCategories();
  List<String> get availableRegions => _matchService.getAvailableRegions();

  /// 자동매칭 실행
  Future<void> performAutoMatch({
    required String campaignId,
    required MatchCriteria criteria,
    int maxResults = 20,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final request = AutoMatchRequest(
        campaignId: campaignId,
        criteria: criteria,
        maxResults: maxResults,
      );

      final result = await _matchService.performAutoMatch(request);
      
      _lastMatchResult = result;
      _currentCriteria = criteria;
      
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Auto match error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 매칭 조건 업데이트
  void updateCriteria(MatchCriteria newCriteria) {
    _currentCriteria = newCriteria;
    notifyListeners();
  }

  /// 결과 초기화
  void clearResults() {
    _lastMatchResult = null;
    _currentCriteria = null;
    _error = null;
    notifyListeners();
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 매칭 점수에 따른 색상 반환
  Color getScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF4CAF50); // 초록색 - 매우 좋음
    if (score >= 0.6) return const Color(0xFF2196F3); // 파란색 - 좋음
    if (score >= 0.4) return const Color(0xFFFF9800); // 주황색 - 보통
    return const Color(0xFF9E9E9E); // 회색 - 낮음
  }

  /// 매칭 점수 텍스트 반환
  String getScoreText(double score) {
    if (score >= 0.8) return '매우 적합';
    if (score >= 0.6) return '적합';
    if (score >= 0.4) return '보통';
    return '낮음';
  }
}
