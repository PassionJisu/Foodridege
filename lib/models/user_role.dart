enum UserRole {
  youth('youth', '이용자', isProvider: false),
  restaurantOwner('restaurant_owner', '학생식당 담당자', isProvider: true),
  driver('driver', '운송 기사님', isProvider: true),
  admin('admin', '관리자', isProvider: true);

  const UserRole(this.value, this.label, {required this.isProvider});

  final String value;
  final String label;
  final bool isProvider;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.youth,
    );
  }
}
