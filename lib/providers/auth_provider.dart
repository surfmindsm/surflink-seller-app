import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  // 로컬 저장소에서 사용자 정보 로드
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        // 실제 구현에서는 JSON 파싱 필요
        // _user = User.fromJson(json.decode(userJson));
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));
      
      // 임시 사용자 데이터 (실제로는 API에서 받아옴)
      _user = User(
        id: '1',
        email: email,
        name: '홍길동',
        type: email.contains('seller') ? UserType.seller : UserType.influencer,
        status: UserStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 저장소에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 회원가입
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required UserType type,
    String? phone,
    String? company,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));
      
      // 임시 사용자 데이터 생성
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        type: type,
        status: UserStatus.active,
        phone: phone,
        company: company,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 저장소에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
