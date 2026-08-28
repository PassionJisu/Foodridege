import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/attached_photo.dart';
import '../models/chingu.dart';

class ChinguProvider with ChangeNotifier {
  ChinguProvider() {
    _teams = List.of(SeedData.teams);
    _matches = List.of(SeedData.matches);
    _reviews = List.of(SeedData.seedReviews);
    for (final t in _teams) {
      _ticketRemaining[t.id] = t.ticketQuota;
    }
  }

  late List<CulinaryTeam> _teams;
  late List<CulinaryMatch> _matches;
  final List<MealTicket> _tickets = [];
  late List<MatchReview> _reviews;
  final Map<String, int> _ticketRemaining = {};
  DateTime? _lastCheerDay;
  String? _cheeredTeamIdToday;
  final Set<String> _reviewUnlockedMatchIds = {};

  List<CulinaryTeam> get teams => List.unmodifiable(_teams);
  List<CulinaryMatch> get matches => List.unmodifiable(_matches);
  List<MealTicket> get tickets => List.unmodifiable(_tickets);
  List<MatchReview> get reviews => List.unmodifiable(_reviews);

  List<CulinaryMatch> get bookableMatches =>
      _matches.where((m) => m.isWithinBookingWindow).toList();

  CulinaryTeam teamById(String id) =>
      _teams.firstWhere((t) => t.id == id, orElse: () => _teams.first);

  String eventTitle(CulinaryMatch match) => teamById(match.teamId).name;

  int remainingTicketsForTeam(String teamId) => _ticketRemaining[teamId] ?? 0;

  List<CulinaryTeam> get rankedTeams {
    final copy = [..._teams];
    copy.sort((a, b) => b.cheers.compareTo(a.cheers));
    return copy;
  }

  List<MealTicket> ticketsFor(String userId) {
    return _tickets.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  MealTicket? activeTicketFor(String userId, String matchId) {
    try {
      return _tickets.firstWhere(
        (t) =>
            t.userId == userId &&
            t.matchId == matchId &&
            t.status != TicketStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  bool hasTicket(String userId, String matchId) =>
      activeTicketFor(userId, matchId) != null;

  bool hasIssuedTicket(String userId, String matchId) {
    final ticket = activeTicketFor(userId, matchId);
    return ticket?.status == TicketStatus.issued;
  }

  bool hasTicketOnSameDay(String userId, DateTime matchDate) {
    final day = DateTime(matchDate.year, matchDate.month, matchDate.day);
    for (final t in _tickets) {
      if (t.userId != userId || t.status == TicketStatus.cancelled) continue;
      final m = _matches.firstWhere((x) => x.id == t.matchId);
      final md = DateTime(m.date.year, m.date.month, m.date.day);
      if (md == day) return true;
    }
    return false;
  }

  List<MatchReview> reviewsFor(String matchId) {
    final list = _reviews.where((r) => r.matchId == matchId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<MatchReview> reviewsForTeam(String teamId) {
    final matchIds =
        _matches.where((m) => m.teamId == teamId).map((m) => m.id).toSet();
    final list = _reviews.where((r) => matchIds.contains(r.matchId)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  double averageStarsForTeam(String teamId) {
    final list = reviewsForTeam(teamId);
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (s, r) => s + r.stars) / list.length;
  }

  bool alreadyReviewed(String userId, String matchId) {
    return _reviews.any((r) => r.userId == userId && r.matchId == matchId);
  }

  bool canCheerToday(String teamId) {
    _resetCheerIfNewDay();
    return _cheeredTeamIdToday == null;
  }

  bool alreadyCheeredToday(String teamId) {
    _resetCheerIfNewDay();
    return _cheeredTeamIdToday == teamId;
  }

  void _resetCheerIfNewDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastCheerDay == null || _lastCheerDay != today) {
      _lastCheerDay = today;
      _cheeredTeamIdToday = null;
    }
  }

  void unlockReviewForDemo(String matchId) {
    _reviewUnlockedMatchIds.add(matchId);
    // Also mark a reserved ticket as issued for demo user flow if present
    notifyListeners();
  }

  bool isReviewUnlocked(String matchId) =>
      _reviewUnlockedMatchIds.contains(matchId);

  String? reserveTicket({
    required String userId,
    required String matchId,
  }) {
    final match = _matches.firstWhere((m) => m.id == matchId);
    if (!match.isWithinBookingWindow) {
      return '예약 가능한 일정이 아닙니다.';
    }
    if (match.isCompleted) return '종료된 일정은 예약할 수 없습니다.';
    if (activeTicketFor(userId, matchId) != null) {
      return '이미 이 일정의 식권을 예약했습니다.';
    }
    if (hasTicketOnSameDay(userId, match.date)) {
      return '같은 날에는 식권을 한 장만 예약할 수 있습니다.';
    }
    final teamId = match.teamId;
    final left = _ticketRemaining[teamId] ?? 0;
    if (left <= 0) return '해당 학교 식권이 모두 소진되었습니다. (학교당 100장)';

    _ticketRemaining[teamId] = left - 1;
    // 전액(1,000원) 결제 후 즉시 발권 · 리뷰 해금 (키오스크 현장결제 없음)
    _tickets.add(
      MealTicket(
        id: 't-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        matchId: matchId,
        status: TicketStatus.issued,
        createdAt: DateTime.now(),
        issuedAt: DateTime.now(),
      ),
    );
    _reviewUnlockedMatchIds.add(matchId);
    notifyListeners();
    return null;
  }

  String? cancelTicket(String ticketId) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index < 0) return '식권을 찾을 수 없습니다.';
    final ticket = _tickets[index];
    if (ticket.status != TicketStatus.reserved) {
      return '예약 상태의 식권만 취소할 수 있습니다.';
    }
    final match = _matches.firstWhere((m) => m.id == ticket.matchId);
    if (!match.canCancelReservation) {
      return '경기 3일 전까지만 취소할 수 있습니다.';
    }
    _tickets[index] = ticket.copyWith(status: TicketStatus.cancelled);
    _ticketRemaining[match.teamId] =
        (_ticketRemaining[match.teamId] ?? 0) + 1;
    notifyListeners();
    return null;
  }

  String? issueAtKiosk(String ticketId) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index < 0) return '식권을 찾을 수 없습니다.';
    final ticket = _tickets[index];
    if (ticket.status != TicketStatus.reserved) {
      return '예약된 식권만 발권할 수 있습니다.';
    }
    _tickets[index] = ticket.copyWith(
      status: TicketStatus.issued,
      issuedAt: DateTime.now(),
    );
    _reviewUnlockedMatchIds.add(ticket.matchId);
    notifyListeners();
    return null;
  }

  /// 데모: 키오스크 결제 완료 시뮬레이션 (예약 창 밖 일정도 리뷰 해금)
  String? simulateKioskPayment({
    required String userId,
    required String matchId,
  }) {
    var ticket = activeTicketFor(userId, matchId);
    if (ticket != null && ticket.status == TicketStatus.reserved) {
      return issueAtKiosk(ticket.id);
    }
    _reviewUnlockedMatchIds.add(matchId);
    notifyListeners();
    return null;
  }

  bool canWriteReview(String userId, String matchId) {
    if (alreadyReviewed(userId, matchId)) return false;
    if (isReviewUnlocked(matchId)) return true;
    return hasIssuedTicket(userId, matchId);
  }

  String? submitReview({
    required String userId,
    required String userName,
    required String matchId,
    required int stars,
    required String comment,
    String? photoNote,
    AttachedPhoto? photo,
  }) {
    if (stars < 0 || stars > 5) return '별점은 0~5점이어야 합니다.';
    if (comment.trim().isEmpty) return '리뷰 내용을 입력해 주세요.';
    if (!canWriteReview(userId, matchId)) {
      return '식권 결제 완료 후에만 리뷰를 작성할 수 있습니다.';
    }
    if (alreadyReviewed(userId, matchId)) {
      return '이미 이 일정을 평가했습니다.';
    }
    final masked = userName.isEmpty ? '익명' : '${userName.substring(0, 1)}**';
    _reviews.add(
      MatchReview(
        id: 'rv-${DateTime.now().millisecondsSinceEpoch}',
        matchId: matchId,
        userId: userId,
        displayName: '미식가 $masked',
        stars: stars,
        comment: comment.trim(),
        createdAt: DateTime.now(),
        photoNote: photoNote,
        photo: photo,
      ),
    );
    final ticket = activeTicketFor(userId, matchId);
    if (ticket != null) {
      final tIndex = _tickets.indexWhere((t) => t.id == ticket.id);
      if (tIndex >= 0) {
        _tickets[tIndex] = _tickets[tIndex].copyWith(reviewed: true);
      }
    }
    notifyListeners();
    return null;
  }

  String? cheer(String teamId) {
    _resetCheerIfNewDay();
    if (_cheeredTeamIdToday != null) {
      return '하루에 1곳만 응원할 수 있어요!';
    }
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index < 0) return '팀을 찾을 수 없습니다.';
    _teams[index] = _teams[index].copyWith(cheers: _teams[index].cheers + 1);
    _cheeredTeamIdToday = teamId;
    _lastCheerDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    notifyListeners();
    return null;
  }

  /// 데모용 실시간 랭킹 — 다른 이용자 응원을 흉내 내 순위가 움직이게 함.
  void addCrowdCheers(String teamId, int amount) {
    if (amount <= 0) return;
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index < 0) return;
    _teams[index] = _teams[index].copyWith(
      cheers: _teams[index].cheers + amount,
    );
    notifyListeners();
  }
}
