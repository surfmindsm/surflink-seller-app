import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft_model.dart';

/// 임시저장 서비스
class DraftService {
  static const String _keyPrefix = 'draft_';
  static const Duration _autosaveInterval = Duration(seconds: 30);
  
  /// 모든 임시저장 조회
  Future<List<Draft>> getAllDrafts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final draftKeys = keys.where((key) => key.startsWith('${_keyPrefix}${userId}_'));
      
      List<Draft> drafts = [];
      for (String key in draftKeys) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            drafts.add(Draft.fromJson(json));
          } catch (e) {
            debugPrint('Draft parsing error for key $key: $e');
            // 오류가 있는 임시저장 제거
            prefs.remove(key);
          }
        }
      }
      
      // 생성일 기준 내림차순 정렬
      drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return drafts;
    } catch (e) {
      debugPrint('Error loading drafts: $e');
      return [];
    }
  }
  
  /// 특정 타입의 임시저장 조회
  Future<List<Draft>> getDraftsByType(String userId, DraftType type) async {
    final allDrafts = await getAllDrafts(userId);
    return allDrafts.where((draft) => draft.type == type).toList();
  }
  
  /// 임시저장 저장
  Future<bool> saveDraft(Draft draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${draft.userId}_${draft.type.name}_${draft.id}';
      final jsonString = jsonEncode(draft.toJson());
      
      await prefs.setString(key, jsonString);
      debugPrint('Draft saved: $key');
      
      return true;
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return false;
    }
  }
  
  /// 임시저장 삭제
  Future<bool> deleteDraft(String userId, DraftType type, String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${userId}_${type.name}_$draftId';
      
      final success = await prefs.remove(key);
      if (success) {
        debugPrint('Draft deleted: $key');
      }
      
      return success;
    } catch (e) {
      debugPrint('Error deleting draft: $e');
      return false;
    }
  }
  
  /// 특정 임시저장 조회
  Future<Draft?> getDraft(String userId, DraftType type, String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${userId}_${type.name}_$draftId';
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Draft.fromJson(json);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return null;
    }
  }
  
  /// 자동 저장
  Future<bool> autosave(Draft draft) async {
    final updatedDraft = draft.copyWith(
      lastSavedAt: DateTime.now(),
      isAutosaved: true,
    );
    
    return await saveDraft(updatedDraft);
  }
  
  /// 만료된 임시저장 정리
  Future<int> cleanupExpiredDrafts(String userId, {Duration? maxAge}) async {
    maxAge ??= const Duration(days: 30); // 기본 30일
    
    try {
      final allDrafts = await getAllDrafts(userId);
      final now = DateTime.now();
      int deletedCount = 0;
      
      for (Draft draft in allDrafts) {
        final age = now.difference(draft.lastSavedAt);
        if (age > maxAge) {
          final success = await deleteDraft(userId, draft.type, draft.id);
          if (success) {
            deletedCount++;
          }
        }
      }
      
      debugPrint('Cleaned up $deletedCount expired drafts');
      return deletedCount;
    } catch (e) {
      debugPrint('Error cleaning up drafts: $e');
      return 0;
    }
  }
  
  /// 중복 임시저장 정리
  Future<int> cleanupDuplicateDrafts(String userId, DraftType type) async {
    try {
      final drafts = await getDraftsByType(userId, type);
      if (drafts.length <= 1) return 0;
      
      // 최신 것을 제외한 나머지 삭제
      drafts.sort((a, b) => b.lastSavedAt.compareTo(a.lastSavedAt));
      int deletedCount = 0;
      
      for (int i = 1; i < drafts.length; i++) {
        final success = await deleteDraft(userId, type, drafts[i].id);
        if (success) {
          deletedCount++;
        }
      }
      
      debugPrint('Cleaned up $deletedCount duplicate drafts for type ${type.name}');
      return deletedCount;
    } catch (e) {
      debugPrint('Error cleaning up duplicate drafts: $e');
      return 0;
    }
  }
  
  /// 임시저장 통계
  Future<DraftStatistics> getDraftStatistics(String userId) async {
    try {
      final allDrafts = await getAllDrafts(userId);
      final now = DateTime.now();
      
      int totalSize = 0;
      Map<DraftType, int> typeCount = {};
      int todayCount = 0;
      int weekCount = 0;
      
      for (Draft draft in allDrafts) {
        // 크기 계산 (대략적)
        totalSize += jsonEncode(draft.toJson()).length;
        
        // 타입별 개수
        typeCount[draft.type] = (typeCount[draft.type] ?? 0) + 1;
        
        // 오늘 생성된 개수
        final daysDiff = now.difference(draft.createdAt).inDays;
        if (daysDiff == 0) {
          todayCount++;
        }
        
        // 이번 주 생성된 개수
        if (daysDiff <= 7) {
          weekCount++;
        }
      }
      
      return DraftStatistics(
        totalCount: allDrafts.length,
        totalSizeBytes: totalSize,
        typeCount: typeCount,
        todayCount: todayCount,
        weekCount: weekCount,
        oldestDraft: allDrafts.isNotEmpty 
            ? allDrafts.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b)
            : null,
        newestDraft: allDrafts.isNotEmpty 
            ? allDrafts.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
            : null,
      );
    } catch (e) {
      debugPrint('Error getting draft statistics: $e');
      return DraftStatistics(
        totalCount: 0,
        totalSizeBytes: 0,
        typeCount: {},
        todayCount: 0,
        weekCount: 0,
      );
    }
  }
  
  /// 임시저장 검색
  Future<List<Draft>> searchDrafts(String userId, String query) async {
    if (query.trim().isEmpty) {
      return await getAllDrafts(userId);
    }
    
    final allDrafts = await getAllDrafts(userId);
    final lowercaseQuery = query.toLowerCase();
    
    return allDrafts.where((draft) {
      return draft.title.toLowerCase().contains(lowercaseQuery) ||
             draft.content.toLowerCase().contains(lowercaseQuery) ||
             (draft.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ?? false);
    }).toList();
  }
  
  /// 임시저장 복제
  Future<Draft?> duplicateDraft(Draft original) async {
    try {
      final newDraft = Draft(
        id: _generateDraftId(),
        userId: original.userId,
        type: original.type,
        title: '${original.title} (복사본)',
        content: original.content,
        metadata: Map<String, dynamic>.from(original.metadata),
        tags: original.tags != null ? List<String>.from(original.tags!) : null,
        createdAt: DateTime.now(),
        lastSavedAt: DateTime.now(),
        isAutosaved: false,
      );
      
      final success = await saveDraft(newDraft);
      return success ? newDraft : null;
    } catch (e) {
      debugPrint('Error duplicating draft: $e');
      return null;
    }
  }
  
  /// 임시저장 내보내기 (JSON)
  Future<String> exportDrafts(String userId) async {
    final drafts = await getAllDrafts(userId);
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'total_count': drafts.length,
      'drafts': drafts.map((draft) => draft.toJson()).toList(),
    };
    
    return jsonEncode(exportData);
  }
  
  /// 임시저장 가져오기 (JSON)
  Future<int> importDrafts(String userId, String jsonData) async {
    try {
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;
      final draftsData = importData['drafts'] as List<dynamic>;
      
      int importedCount = 0;
      for (var draftData in draftsData) {
        try {
          final draft = Draft.fromJson(draftData as Map<String, dynamic>);
          // 사용자 ID 변경
          final updatedDraft = draft.copyWith(
            userId: userId,
            id: _generateDraftId(), // 새로운 ID 생성
            createdAt: DateTime.now(),
            lastSavedAt: DateTime.now(),
          );
          
          final success = await saveDraft(updatedDraft);
          if (success) {
            importedCount++;
          }
        } catch (e) {
          debugPrint('Error importing individual draft: $e');
        }
      }
      
      debugPrint('Imported $importedCount drafts');
      return importedCount;
    } catch (e) {
      debugPrint('Error importing drafts: $e');
      return 0;
    }
  }
  
  /// 임시저장 ID 생성
  String _generateDraftId() {
    return 'draft_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
  
  /// 스토리지 사용량 조회
  Future<int> getStorageUsage(String userId) async {
    final statistics = await getDraftStatistics(userId);
    return statistics.totalSizeBytes;
  }
  
  /// 스토리지 정리
  Future<int> cleanupStorage(String userId, {int? maxSizeBytes}) async {
    maxSizeBytes ??= 1024 * 1024 * 10; // 기본 10MB
    
    int currentUsage = await getStorageUsage(userId);
    if (currentUsage <= maxSizeBytes) {
      return 0;
    }
    
    // 오래된 순으로 삭제
    final drafts = await getAllDrafts(userId);
    drafts.sort((a, b) => a.lastSavedAt.compareTo(b.lastSavedAt));
    
    int deletedCount = 0;
    for (Draft draft in drafts) {
      if (currentUsage <= maxSizeBytes) break;
      
      final success = await deleteDraft(userId, draft.type, draft.id);
      if (success) {
        deletedCount++;
        // 대략적인 크기 계산
        currentUsage -= jsonEncode(draft.toJson()).length;
      }
    }
    
    debugPrint('Cleaned up $deletedCount drafts to reduce storage usage');
    return deletedCount;
  }
}
