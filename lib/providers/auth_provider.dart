import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _appUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  UserRole? get role => _appUser?.role;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _appUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _appUser = await _authService.getUserProfile(user.uid);
    _status = _appUser == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _appUser = await _authService.getCurrentAppUser();
      _status = _appUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _appUser = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    required DateTime birthDate,
    required String rrnLastDigit,
    required String phone,
    String? address,
    String? schoolInfo,
    String? businessRegistrationNumber,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _appUser = await _authService.signUp(
        email: email,
        password: password,
        role: role,
        name: name,
        birthDate: birthDate,
        rrnLastDigit: rrnLastDigit,
        phone: phone,
        address: address,
        schoolInfo: schoolInfo,
        businessRegistrationNumber: businessRegistrationNumber,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> incrementChinguUsage() async {
    final user = _appUser;
    if (user == null) return;
    final next = user.copyWith(chinguUsageCount: user.chinguUsageCount + 1);
    await _persistStats(next);
  }

  Future<void> addRewardStack() async {
    final user = _appUser;
    if (user == null) return;
    final next = user.copyWith(rewardStack: user.rewardStack + 1);
    await _persistStats(next);
  }

  Future<void> _persistStats(AppUser next) async {
    _appUser = next;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('users').doc(next.uid).update({
        'vendingUsageCount': next.vendingUsageCount,
        'chinguUsageCount': next.chinguUsageCount,
        'rewardStack': next.rewardStack,
        'mealCouponCount': next.mealCouponCount,
        'freeMealCount': next.freeMealCount,
      });
    } catch (e) {
      debugPrint('Failed to persist user stats: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다.';
      case 'profile-not-found':
        return e.message ?? '프로필을 찾을 수 없습니다.';
      default:
        return e.message ?? '인증 중 오류가 발생했습니다.';
    }
  }
}
