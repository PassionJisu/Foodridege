enum MatchStatus { live, scheduled, completed }

enum TicketStatus { reserved, issued, cancelled }

class CulinaryTeam {
  const CulinaryTeam({
    required this.id,
    required this.name,
    required this.region,
    required this.cheers,
    required this.schoolName,
    required this.cafeteriaVenue,
    this.ticketQuota = 100,
  });

  final String id;
  final String name;
  final String region;
  final int cheers;
  final String schoolName;
  final String cafeteriaVenue;
  final int ticketQuota;

  CulinaryTeam copyWith({int? cheers}) {
    return CulinaryTeam(
      id: id,
      name: name,
      region: region,
      cheers: cheers ?? this.cheers,
      schoolName: schoolName,
      cafeteriaVenue: cafeteriaVenue,
      ticketQuota: ticketQuota,
    );
  }
}

/// 단일 팀 일정 (토너먼트 vs 형식 없음).
class CulinaryMatch {
  const CulinaryMatch({
    required this.id,
    required this.roundLabel,
    required this.teamId,
    required this.menu,
    required this.venue,
    required this.date,
    this.time = '14:00',
    required this.status,
  });

  final String id;
  final String roundLabel;
  final String teamId;
  final String menu;
  final String venue;
  final DateTime date;
  final String time;
  final MatchStatus status;

  bool get isLive => status == MatchStatus.live;
  bool get isCompleted => status == MatchStatus.completed;

  bool get canCancelReservation {
    final deadline = date.subtract(const Duration(days: 3));
    return DateTime.now().isBefore(deadline);
  }

  bool get canReview {
    return isCompleted || DateTime.now().isAfter(date);
  }

  /// 데모: 9월 키친 일정 등 다가오는(미완료) 일정을 예약 목록에 노출.
  bool get isWithinBookingWindow {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    return !isCompleted && !day.isBefore(today);
  }
}

class MealTicket {
  const MealTicket({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.status,
    required this.createdAt,
    this.issuedAt,
    this.reviewed = false,
  });

  final String id;
  final String userId;
  final String matchId;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? issuedAt;
  final bool reviewed;

  MealTicket copyWith({
    TicketStatus? status,
    DateTime? issuedAt,
    bool? reviewed,
  }) {
    return MealTicket(
      id: id,
      userId: userId,
      matchId: matchId,
      status: status ?? this.status,
      createdAt: createdAt,
      issuedAt: issuedAt ?? this.issuedAt,
      reviewed: reviewed ?? this.reviewed,
    );
  }
}

class MatchReview {
  const MatchReview({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.stars,
    required this.comment,
    required this.createdAt,
    this.photoNote,
  });

  final String id;
  final String matchId;
  final String userId;
  final String displayName;
  final int stars; // 0–5
  final String comment;
  final DateTime createdAt;
  final String? photoNote;
}
