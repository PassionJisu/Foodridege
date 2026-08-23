enum UserRole {
  student('student', '대학생', isProvider: false),
  resident('resident', '지역민', isProvider: false),
  owner('owner', '점주', isProvider: true),
  org('org', '기관', isProvider: true),
  driver('driver', '운송기사', isProvider: true),
  admin('admin', '관리자', isProvider: true);

  const UserRole(this.value, this.label, {required this.isProvider});

  final String value;
  final String label;
  final bool isProvider;

  bool get isConsumer => this == student || this == resident;

  static UserRole fromValue(String value) {
    return switch (value) {
      'youth' || 'student' => UserRole.student,
      'resident' => UserRole.resident,
      'restaurant_owner' || 'owner' => UserRole.owner,
      'org' => UserRole.org,
      'driver' => UserRole.driver,
      'admin' => UserRole.admin,
      _ => UserRole.student,
    };
  }
}
