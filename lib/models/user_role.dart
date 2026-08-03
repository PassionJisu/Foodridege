enum UserRole {
  youth('youth', '청년', isProvider: false),
  restaurantOwner('restaurant_owner', '음식점 사장님', isProvider: true),
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
