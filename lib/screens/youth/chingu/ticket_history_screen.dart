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
    final chingu = context.watch<ChinguProvider>();
    final tickets = chingu.ticketsFor(auth.appUser!.uid);

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
                  final match = chingu.matches.firstWhere((m) => m.id == ticket.matchId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.chinguBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.roundLabel, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                        const SizedBox(height: 12),
                        if (ticket.status == TicketStatus.reserved) ...[
                          const Text(
                            '현장 키오스크에서 보증금 제외 1,000원으로 발권됩니다.',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: match.canCancelReservation
                                      ? () {
                                          final error = chingu.cancelTicket(ticket.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(error ?? '식권 예약이 취소되었습니다.')),
                                          );
                                        }
                                      : null,
                                  child: const Text('예약 취소'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    final error = chingu.issueAtKiosk(ticket.id);
                                    if (error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                      return;
                                    }
                                    await auth.incrementChinguUsage();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('키오스크 발권이 완료되었습니다. (1,000원 · 보증금 제외)'),
                                        ),
                                      );
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('키오스크 발권'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (ticket.status == TicketStatus.issued &&
                            !ticket.reviewed) ...[
                          const SizedBox(height: 10),
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
        return '예약 · 현장 발권 대기';
      case TicketStatus.issued:
        return ticket.reviewed ? '발권 · 평가 완료' : '발권 완료 · 평가 대기';
      case TicketStatus.cancelled:
        return '취소됨';
    }
  }
}
