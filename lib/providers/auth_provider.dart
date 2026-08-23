import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import '../services/demo_auth_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  AppUser? _appUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  UserRole? get role => _appUser?.role;

  Future<void> initialize() async {
    _status = AuthStatus.unauthenticated;
    _appUser = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = DemoAuthStore.signIn(email, password);
      if (user == null) {
        _errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        notifyListeners();
        return false;
      }
      _appUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
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
    String? adminSecret,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = AppUser(
        uid: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim().toLowerCase(),
        role: role,
        name: name.trim(),
        birthDate: birthDate,
        rrnLastDigit: rrnLastDigit,
        phone: phone.trim(),
        address: address?.trim(),
        schoolInfo: schoolInfo?.trim(),
        businessRegistrationNumber: businessRegistrationNumber?.trim(),
        createdAt: DateTime.now(),
      );
      final error = DemoAuthStore.signUp(
        user: user,
        password: password,
        adminSecret: adminSecret,
      );
      if (error != null) {
        _errorMessage = error;
        notifyListeners();
        return false;
      }
      _appUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> incrementChinguUsage() async {
    final user = _appUser;
    if (user == null) return;
    final next = user.copyWith(chinguUsageCount: user.chinguUsageCount + 1);
    _appUser = next;
    DemoAuthStore.replaceUser(next);
    notifyListeners();
  }

  Future<void> addRewardStack() async {
    final user = _appUser;
    if (user == null) return;
    final next = user.copyWith(rewardStack: user.rewardStack + 1);
    _appUser = next;
    DemoAuthStore.replaceUser(next);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
