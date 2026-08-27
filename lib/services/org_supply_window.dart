/// 기관 수거 신청 접수 창: 매일 11:00 오픈, 15:00 마감.
/// 15:00 이후에는 다음 날 11:00까지 비활성화.
class OrgSupplyWindow {
  static const openHour = 11;
  static const closeHour = 15;

  /// 데모 시연용. On이면 시간 창과 관계없이 접수를 연다.
  static bool demoForceOpen = false;

  static bool isOpen([DateTime? now]) {
    if (demoForceOpen) return true;
    final t = now ?? DateTime.now();
    final minutes = t.hour * 60 + t.minute;
    return minutes >= openHour * 60 && minutes < closeHour * 60;
  }

  static DateTime nextOpenAt([DateTime? now]) {
    final t = now ?? DateTime.now();
    final todayOpen = DateTime(t.year, t.month, t.day, openHour);
    if (t.isBefore(todayOpen)) return todayOpen;
    if (isOpen(t)) return todayOpen;
    return todayOpen.add(const Duration(days: 1));
  }

  static DateTime closesAt([DateTime? now]) {
    final t = now ?? DateTime.now();
    return DateTime(t.year, t.month, t.day, closeHour);
  }

  static String statusMessage([DateTime? now]) {
    if (demoForceOpen) {
      return '데모 모드로 접수를 열어 두었습니다. 실제 운영은 오전 11시~오후 3시입니다.';
    }
    final t = now ?? DateTime.now();
    if (isOpen(t)) {
      return '오늘은 오후 3시까지 접수합니다. 신청과 동시에 자판기 번호가 배정됩니다.';
    }
    final next = nextOpenAt(t);
    final sameDay = next.year == t.year && next.month == t.month && next.day == t.day;
    if (sameDay) {
      return '접수는 오전 11시에 열립니다. 오후 3시에 마감됩니다.';
    }
    return '오늘은 오후 3시에 마감되었습니다. 다음 접수는 내일 오전 11시입니다.';
  }
}
