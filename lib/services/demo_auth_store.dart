import '../models/app_user.dart';
import '../models/user_role.dart';

class DemoAuthStore {
  DemoAuthStore._();

  static const password = 'demo1234';
  static const adminSecret = 'FOODRIDGE_ADMIN_2026';

  static const universities = [
    '전남대학교',
    '광주교육대학교',
    '국립목포대학교',
    '국립목포해양대학교',
    '국립순천대학교',
  ];

  static final List<_DemoCredential> _accounts = [
    _DemoCredential(
      email: 'student@foodridge.kr',
      user: AppUser(
        uid: 'demo-student',
        email: 'student@foodridge.kr',
        role: UserRole.student,
        name: '김대학',
        birthDate: DateTime(2003, 3, 12),
        rrnLastDigit: '4',
        phone: '010-2000-0001',
        schoolInfo: '전남대학교',
        studentOrigin: StudentOrigin.korean,
        createdAt: DateTime(2026, 3, 2),
        vendingUsageCount: 8,
        chinguUsageCount: 2,
        rewardStack: 2,
        mealCouponCount: 2,
        reviewCount: 2,
      ),
    ),
    _DemoCredential(
      email: 'owner@foodridge.kr',
      user: AppUser(
        uid: 'demo-owner',
        email: 'owner@foodridge.kr',
        role: UserRole.owner,
        name: '최점주',
        birthDate: DateTime(1986, 1, 20),
        rrnLastDigit: '1',
        phone: '010-2000-0003',
        businessRegistrationNumber: '123-45-67890',
        createdAt: DateTime(2026, 2, 18),
        helpedYouthCount: 128,
      ),
    ),
    _DemoCredential(
      email: 'org@foodridge.kr',
      user: AppUser(
        uid: 'demo-org',
        email: 'org@foodridge.kr',
        role: UserRole.org,
        name: '광주 먹거리정책',
        birthDate: DateTime(1980, 5, 1),
        rrnLastDigit: '1',
        phone: '062-200-0004',
        schoolInfo: '광주광역시',
        createdAt: DateTime(2026, 1, 10),
      ),
    ),
    _DemoCredential(
      email: 'driver@foodridge.kr',
      user: AppUser(
        uid: 'demo-driver',
        email: 'driver@foodridge.kr',
        role: UserRole.driver,
        name: '이운송',
        birthDate: DateTime(1988, 11, 3),
        rrnLastDigit: '1',
        phone: '010-2000-0005',
        createdAt: DateTime(2026, 2, 1),
      ),
    ),
    _DemoCredential(
      email: 'admin@foodridge.kr',
      user: AppUser(
        uid: 'demo-admin',
        email: 'admin@foodridge.kr',
        role: UserRole.admin,
        name: '관리자',
        birthDate: DateTime(1982, 9, 15),
        rrnLastDigit: '1',
        phone: '010-2000-0006',
        createdAt: DateTime(2026, 1, 5),
        vendingUsageCount: 3,
        chinguUsageCount: 1,
        mealCouponCount: 2,
        helpedYouthCount: 0,
      ),
    ),
  ];

  static List<({String role, String email})> get directory => [
        (role: '대학생', email: 'student@foodridge.kr'),
        (role: '점주', email: 'owner@foodridge.kr'),
        (role: '기관', email: 'org@foodridge.kr'),
        (role: '운송기사', email: 'driver@foodridge.kr'),
        (role: '관리자', email: 'admin@foodridge.kr'),
      ];

  static AppUser? signIn(String email, String password) {
    final key = email.trim().toLowerCase();
    for (final account in _accounts) {
      if (account.email == key && password == account.password) {
        return account.user;
      }
    }
    return null;
  }

  static String? signUp({
    required AppUser user,
    required String password,
    String? adminSecret,
  }) {
    if (user.role == UserRole.admin && adminSecret != DemoAuthStore.adminSecret) {
      return '관리자 시크릿 키가 올바르지 않습니다.';
    }
    final key = user.email.trim().toLowerCase();
    if (_accounts.any((account) => account.email == key)) {
      return '이미 사용 중인 이메일입니다.';
    }
    _accounts.add(
      _DemoCredential(email: key, password: password, user: user),
    );
    return null;
  }

  static void replaceUser(AppUser user) {
    final index = _accounts.indexWhere((account) => account.user.uid == user.uid);
    if (index >= 0) {
      _accounts[index] = _DemoCredential(
        email: _accounts[index].email,
        password: _accounts[index].password,
        user: user,
      );
    }
  }

  static void deleteUser(String uid) {
    _accounts.removeWhere((account) => account.user.uid == uid);
  }
}

class _DemoCredential {
  _DemoCredential({
    required this.email,
    required this.user,
    this.password = DemoAuthStore.password,
  });

  final String email;
  final String password;
  final AppUser user;
}
