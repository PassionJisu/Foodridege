enum UserRole {
  student('student', '대학생', isProvider: false, englishLabel: 'University student'),
  youth('youth', '청년', isProvider: false, englishLabel: 'Youth'),
  owner('owner', '점주', isProvider: true, englishLabel: 'Shop owner'),
  org('org', '기관', isProvider: true),
  driver('driver', '운송기사', isProvider: true),
  admin('admin', '관리자', isProvider: true);

  const UserRole(
    this.value,
    this.label, {
    required this.isProvider,
    this.englishLabel,
  });

  final String value;
  final String label;
  final bool isProvider;
  final String? englishLabel;

  bool get showsEnglishSignup =>
      this == student || this == youth || this == owner;

  bool get isConsumer => this == student || this == youth;

  /// 친구카세(식권/응원) 접근 — 대학생 전용 (관리자는 운영용으로 유지)
  bool get canAccessChingu => this == student || this == admin;

  /// 자판기 조회
  bool get canAccessVending =>
      this == student ||
      this == youth ||
      this == org ||
      this == driver ||
      this == admin;

  /// Foodridge(외국인 가게 맵) 접근
  bool get canAccessFoodridge =>
      this == student || this == youth || this == owner || this == admin;

  /// 홈 배너에 이용 카운트(기여 무게·자판기/친구카세 횟수) 표시
  bool get showsUsageStats => this == student || this == youth || this == admin;

  /// 점주 가게/메뉴 등록
  bool get canManageStore => this == owner || this == admin;

  /// 기관 입고 신청 (지점 선택 없음)
  bool get canSubmitSupply => this == org || this == admin;

  /// 자판기 입고·재고 관리
  bool get canManageVending => this == driver || this == admin;

  /// 네이버맵 수거 동선
  bool get canViewPickupRoute => this == driver || this == admin;

  /// 문의/신고
  bool get canUseSupport => this == student || this == youth || this == admin;

  /// 신고 관리
  bool get canManageReports => this == admin;

  static UserRole fromValue(String value) {
    return switch (value) {
      'student' || 'resident' => UserRole.student,
      'youth' => UserRole.youth,
      'restaurant_owner' || 'owner' => UserRole.owner,
      'org' => UserRole.org,
      'driver' => UserRole.driver,
      'admin' => UserRole.admin,
      _ => UserRole.student,
    };
  }
}
