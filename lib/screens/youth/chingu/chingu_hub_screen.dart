import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/chingu.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';
import 'ticket_deposit_payment_screen.dart';
import 'ticket_history_screen.dart';
import 'chingu_review_write_screen.dart';

class ChinguHubScreen extends StatefulWidget {
  const ChinguHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ChinguHubScreen> createState() => _ChinguHubScreenState();
}

class _ChinguHubScreenState extends State<ChinguHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(
          leadingWidth: 88,
          leading: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            label: const Text('', style: TextStyle(color: Colors.white)),
          ),
          title: const SizedBox.shrink(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketHistoryScreen()),
                );
              },
              child: const Text('식권 예약 내역', style: TextStyle(color: AppColors.gold)),
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: '일정 및 식권 예약'),
              Tab(text: '응원하기'),
              Tab(text: '리뷰'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: const [
            _ScheduleTicketTab(),
            _CheerTab(),
            _ReviewTab(),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTicketTab extends StatelessWidget {
  const _ScheduleTicketTab();

  Future<void> _confirmReserve(
    BuildContext context,
    CulinaryMatch match,
  ) async {
    final chingu = context.read<ChinguProvider>();
    final user = context.read<AuthProvider>().appUser!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.chinguCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '식권 예약 안내',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• 학교당 식권 100장\n'
                '• 같은 날 중복 예약 불가\n'
                '• 보증금 결제 후 예약 확정\n'
                '• 현장 키오스크에서 보증금 제외 1,000원 발권\n\n'
                '식권을 예약하시겠습니까?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldBright,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('확인'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TicketDepositPaymentScreen(
          matchTitle: chingu.eventTitle(match),
        ),
      ),
    );
    if (paid != true || !context.mounted) return;

    final error = chingu.reserveTicket(userId: user.uid, matchId: match.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '식권이 예약되었습니다. 식권 예약 내역에서 확인할 수 있어요.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final user = context.watch<AuthProvider>().appUser!;
    final matches = chingu.bookableMatches;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '9월 키친 일정 · 시간은 모두 14:00입니다.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('예약 가능한 일정이 없습니다.', style: TextStyle(color: Colors.white54)),
            ),
          )
        else
          ...matches.map((match) {
            final team = chingu.teamById(match.teamId);
            final ticket = chingu.activeTicketFor(user.uid, match.id);
            final left = chingu.remainingTicketsForTeam(match.teamId);
            final date = DateFormat('M월 d일 (E)', 'ko').format(match.date);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                border: Border.all(color: AppColors.chinguBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.roundLabel,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('$date · ${match.time}', style: const TextStyle(color: AppColors.gold)),
                  const SizedBox(height: 4),
                  Text(match.venue, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(match.menu, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '잔여 식권 $left / ${team.ticketQuota}장',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: ticket != null ? null : () => _confirmReserve(context, match),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white38,
                        side: const BorderSide(color: Colors.white),
                        minimumSize: const Size.fromHeight(46),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        ticket == null
                            ? '식권 예약'
                            : ticket.status == TicketStatus.issued
                                ? '발권 완료'
                                : '예약됨',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _CheerTab extends StatelessWidget {
  const _CheerTab();

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final teams = chingu.rankedTeams;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '유저당 하루 1회, 한 학교를 응원할 수 있습니다.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ...teams.asMap().entries.map((e) {
          final i = e.key;
          final team = e.value;
          final cheered = chingu.alreadyCheeredToday(team.id);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(team.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${team.schoolName} · 응원 ${team.cheers}',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: TextButton(
              onPressed: cheered || !chingu.canCheerToday(team.id)
                  ? null
                  : () {
                      final err = chingu.cheer(team.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err ?? '${team.name}을(를) 응원했습니다!')),
                      );
                    },
              child: Text(
                cheered ? '오늘 응원함' : '응원',
                style: TextStyle(
                  color: cheered ? Colors.white38 : AppColors.gold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewTab extends StatefulWidget {
  const _ReviewTab();

  @override
  State<_ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<_ReviewTab> {
  String? _selectedTeamId;

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final teamId = _selectedTeamId ?? chingu.teams.first.id;
    final team = chingu.teamById(teamId);
    final teamReviews = chingu.reviewsForTeam(teamId);
    final avg = chingu.averageStarsForTeam(teamId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: teamId,
          dropdownColor: AppColors.chinguCard,
          decoration: const InputDecoration(
            labelText: '대학교 분류',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          items: chingu.teams
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.schoolName),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedTeamId = v),
        ),
        const SizedBox(height: 12),
        Text(
          '${team.schoolName} 평균 ★ ${avg.toStringAsFixed(1)}  (${teamReviews.length}건)',
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.goldBright,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChinguReviewWriteScreen(initialTeamId: teamId),
              ),
            );
          },
          child: const Text('리뷰 작성'),
        ),
        const SizedBox(height: 24),
        const Text(
          '학교별 리뷰',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (teamReviews.isEmpty)
          const Text('아직 리뷰가 없습니다.', style: TextStyle(color: Colors.white38))
        else
          ...teamReviews.map((r) {
            final match = chingu.matches.firstWhere((m) => m.id == r.matchId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${'★' * r.stars}${'☆' * (5 - r.stars)}  ${r.displayName}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${DateFormat('M/d').format(match.date)} ${chingu.eventTitle(match)}\n${r.comment}'
                '${r.photoNote != null ? '\n📷 ${r.photoNote}' : ''}',
                style: const TextStyle(color: Colors.white54),
              ),
              isThreeLine: true,
            );
          }),
      ],
    );
  }
}
