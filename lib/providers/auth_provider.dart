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
      if (user.isStayExpired) {
        DemoAuthStore.deleteUser(user.uid);
        _errorMessage = '체류 기간이 종료되어 자동 탈퇴되었습니다. 다시 회원가입해 주세요.';
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
    StudentOrigin? studentOrigin,
    DateTime? stayStart,
    DateTime? stayEnd,
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
        studentOrigin: studentOrigin,
        stayStart: stayStart,
        stayEnd: stayEnd,
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

  /// 친구카세 결제에서 무료 식권 1장을 사용한다.
  bool consumeMealCoupon() {
    final user = _appUser;
    if (user == null) return false;
    if (user.mealCouponCount > 0) {
      _appUser = user.copyWith(mealCouponCount: user.mealCouponCount - 1);
    } else if (user.freeMealCount > 0) {
      _appUser = user.copyWith(freeMealCount: user.freeMealCount - 1);
    } else {
      return false;
    }
    DemoAuthStore.replaceUser(_appUser!);
    notifyListeners();
    return true;
  }

  /// 리뷰 1회 적립. 5회마다 식권(mealCoupon) +1 (Foodridge2 리워드 규칙).
  Future<String> recordReviewReward() async {
    final user = _appUser;
    if (user == null) return '로그인이 필요합니다.';
    final nextCount = user.reviewCount + 1;
    var coupons = user.mealCouponCount;
    var message = '리뷰가 등록되었습니다. ($nextCount회)';
    if (nextCount % AppUser.reviewsPerCoupon == 0) {
      coupons += 1;
      message =
          '리뷰 $nextCount회 달성! 식권 1장이 발급되었습니다. (보유 $coupons장)';
    } else {
      final left = AppUser.reviewsPerCoupon - (nextCount % AppUser.reviewsPerCoupon);
      message =
          '리뷰가 등록되었습니다. 식권까지 $left회 남았어요. ($nextCount회)';
    }
    final next = user.copyWith(
      reviewCount: nextCount,
      mealCouponCount: coupons,
      rewardStack: user.rewardStack + 1,
    );
    _appUser = next;
    DemoAuthStore.replaceUser(next);
    notifyListeners();
    return message;
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
