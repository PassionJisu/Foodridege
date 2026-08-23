enum MatchStatus { live, scheduled, completed }

enum TicketStatus { reserved, issued, cancelled }

class CulinaryTeam {
  const CulinaryTeam({
    required this.id,
    required this.name,
    required this.region,
    required this.cheers,
  });

  final String id;
  final String name;
  final String region;
  final int cheers;

  CulinaryTeam copyWith({int? cheers}) {
    return CulinaryTeam(
      id: id,
      name: name,
      region: region,
      cheers: cheers ?? this.cheers,
    );
  }
}

class CulinaryMatch {
  const CulinaryMatch({
    required this.id,
    required this.roundLabel,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.menu,
    required this.venue,
    required this.date,
    required this.time,
    required this.status,
  });

  final String id;
  final String roundLabel;
  final String homeTeamId;
  final String awayTeamId;
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
  });

  final String id;
  final String matchId;
  final String userId;
  final String displayName;
  final int stars;
  final String comment;
  final DateTime createdAt;
}
