import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/chingu.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';
import 'chingu_review_write_screen.dart';

class TicketHistoryScreen extends StatelessWidget {
  const TicketHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final chingu = context.watch<ChinguProvider>();
    final tickets = chingu.ticketsFor(user.uid);

    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(title: const Text('식권 예약 내역')),
        body: tickets.isEmpty
            ? const Center(
                child: Text('예약한 식권이 없습니다.', style: TextStyle(color: Colors.white54)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final match =
                      chingu.matches.firstWhere((m) => m.id == ticket.matchId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.chinguBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.roundLabel,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chingu.eventTitle(match),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('yyyy.MM.dd').format(match.date)}  ${match.time}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusLabel(ticket),
                          style: TextStyle(
                            color: ticket.status == TicketStatus.cancelled
                                ? Colors.redAccent
                                : AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ticket.status == TicketStatus.issued &&
                            !ticket.reviewed) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.goldBright,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChinguReviewWriteScreen(
                                      initialTeamId: match.teamId,
                                      initialMatchId: match.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('리뷰 작성'),
                            ),
                          ),
                        ],
                        if (ticket.status == TicketStatus.reserved &&
                            match.canCancelReservation) ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              final error = chingu.cancelTicket(ticket.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error ?? '식권 예약이 취소되었습니다.'),
                                ),
                              );
                            },
                            child: const Text('예약 취소'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _statusLabel(MealTicket ticket) {
    switch (ticket.status) {
      case TicketStatus.reserved:
        return '예약됨';
      case TicketStatus.issued:
        return ticket.reviewed ? '결제 완료 · 평가 완료' : '결제 완료 · 평가 대기';
      case TicketStatus.cancelled:
        return '취소됨';
    }
  }
}
