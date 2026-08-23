import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/chingu.dart';

class ChinguProvider with ChangeNotifier {
  ChinguProvider() {
    _teams = List.of(SeedData.teams);
    _matches = List.of(SeedData.matches);
    _reviews = List.of(SeedData.seedReviews);
  }

  late List<CulinaryTeam> _teams;
  late List<CulinaryMatch> _matches;
  final List<MealTicket> _tickets = [];
  late List<MatchReview> _reviews;
  final Set<String> _cheeredTeamIds = {};

  List<CulinaryTeam> get teams => List.unmodifiable(_teams);
  List<CulinaryMatch> get matches => List.unmodifiable(_matches);
  List<MealTicket> get tickets => List.unmodifiable(_tickets);
  List<MatchReview> get reviews => List.unmodifiable(_reviews);

  CulinaryTeam teamById(String id) =>
      _teams.firstWhere((t) => t.id == id, orElse: () => _teams.first);

  String vsTitle(CulinaryMatch match) =>
      '${teamById(match.homeTeamId).name} vs ${teamById(match.awayTeamId).name}';

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

  List<MatchReview> reviewsFor(String matchId) {
    final list = _reviews.where((r) => r.matchId == matchId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool alreadyReviewed(String userId, String matchId) {
    return _reviews.any((r) => r.userId == userId && r.matchId == matchId);
  }

  bool alreadyCheered(String teamId) => _cheeredTeamIds.contains(teamId);

  String? reserveTicket({
    required String userId,
    required String matchId,
  }) {
    final match = _matches.firstWhere((m) => m.id == matchId);
    if (match.isCompleted) return '종료된 경기는 예약할 수 없습니다.';
    if (activeTicketFor(userId, matchId) != null) {
      return '이미 이 경기의 식권을 예약했습니다. (1인 1매)';
    }
    _tickets.add(
      MealTicket(
        id: 't-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        matchId: matchId,
        status: TicketStatus.reserved,
        createdAt: DateTime.now(),
      ),
    );
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
    notifyListeners();
    return null;
  }

  /// Kiosk issuance: 1,000 KRW excluding deposit.
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
    notifyListeners();
    return null;
  }

  String? submitReview({
    required String userId,
    required String userName,
    required String matchId,
    required int stars,
    required String comment,
  }) {
    final ticket = activeTicketFor(userId, matchId);
    if (ticket == null || ticket.status != TicketStatus.issued) {
      return '식권 예약 후 현장에서 발권한 분만 평가할 수 있습니다.';
    }
    final match = _matches.firstWhere((m) => m.id == matchId);
    if (!match.canReview) {
      return '경기가 끝난 뒤에 평가할 수 있습니다.';
    }
    if (alreadyReviewed(userId, matchId)) {
      return '이미 이 경기를 평가했습니다.';
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
      ),
    );
    final tIndex = _tickets.indexWhere((t) => t.id == ticket.id);
    if (tIndex >= 0) {
      _tickets[tIndex] = _tickets[tIndex].copyWith(reviewed: true);
    }
    notifyListeners();
    return null;
  }

  String? cheer(String teamId) {
    if (_cheeredTeamIds.contains(teamId)) {
      return '이미 응원한 팀입니다.';
    }
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index < 0) return '팀을 찾을 수 없습니다.';
    _teams[index] = _teams[index].copyWith(cheers: _teams[index].cheers + 1);
    _cheeredTeamIds.add(teamId);
    notifyListeners();
    return null;
  }
}
