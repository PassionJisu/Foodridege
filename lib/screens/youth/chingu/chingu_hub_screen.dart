import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/chingu.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';
import 'chingu_ranking_screen.dart';
import 'ticket_history_screen.dart';

class ChinguHubScreen extends StatefulWidget {
  const ChinguHubScreen({super.key, this.initialTab = 1});

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
    final coupons = context.watch<AuthProvider>().appUser?.displayCouponCount ?? 0;

    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(
          leadingWidth: 88,
          leading: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            label: const Text('포스터', style: TextStyle(color: Colors.white)),
          ),
          title: const SizedBox.shrink(),
          actions: [
            Center(
              child: Text(
                '쿠폰 $coupons',
                style: const TextStyle(color: AppColors.gold, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChinguRankingScreen()),
                );
              },
              child: const Text('응원하기', style: TextStyle(color: AppColors.gold)),
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: '대전 현황'),
              Tab(text: '식권 예약'),
              Tab(text: '별점 · 피드백'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: const [
            _StatusTab(),
            _TicketTab(),
            _ReviewTab(),
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab();

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '한 팀씩 돌아가며 펼치는 지역 조리학과 외식 대전',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ...chingu.matches.map((match) => _MatchCard(match: match, compact: true)),
      ],
    );
  }
}

class _TicketTab extends StatelessWidget {
  const _TicketTab();

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '식권 예약',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '식권을 예약하면 현장에서 해당 경기팀의 요리를 체험할 수 있습니다. 식권 예약자에 한해 별점 평가가 가능합니다.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안내 사항', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• 식권은 경기당 1인 1매입니다.'),
              Text('• 경기 3일 전까지 신청 내역에서 취소할 수 있습니다.'),
              Text('• 현장 키오스크에서 보증금 제외 1,000원에 발권합니다. (표시가 1,500원)'),
              Text('• 발권 후 평가를 완료해야 리워드 스택이 1 증가합니다.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicketHistoryScreen()),
              );
            },
            child: const Text('식권 신청 내역'),
          ),
        ),
        ...chingu.matches
            .where((m) => !m.isCompleted)
            .map((match) => _MatchCard(match: match, showReserve: true)),
      ],
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab();

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final matches = chingu.matches.where((m) => m.canReview).toList();
    if (matches.isEmpty) {
      return const Center(
        child: Text('아직 평가할 수 있는 경기가 없습니다.', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: matches.map((match) => _ReviewMatchBlock(match: match)).toList(),
    );
  }
}

class _ReviewMatchBlock extends StatelessWidget {
  const _ReviewMatchBlock({required this.match});

  final CulinaryMatch match;

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final user = context.watch<AuthProvider>().appUser!;
    final reviews = chingu.reviewsFor(match.id);
    final canWrite = chingu.hasIssuedTicket(user.uid, match.id) &&
        !chingu.alreadyReviewed(user.uid, match.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.chinguBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      match.roundLabel,
                      style: const TextStyle(color: AppColors.gold, fontSize: 11),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy. MM. dd').format(match.date),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                chingu.vsTitle(match),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(match.menu, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF3A3A3A))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '평가 ${reviews.length}건',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF3A3A3A))),
          ],
        ),
        const SizedBox(height: 12),
        if (canWrite)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () => _openWrite(context, match),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
              ),
              child: const Text('이 경기 평가하기 (리워드 +1)'),
            ),
          ),
        if (!chingu.hasIssuedTicket(user.uid, match.id))
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '현장 발권 이용자만 평가할 수 있습니다.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ...reviews.map(
          (review) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.chinguBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '★' * review.stars + '☆' * (5 - review.stars),
                      style: const TextStyle(color: AppColors.gold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.displayName,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.comment, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _openWrite(BuildContext context, CulinaryMatch match) async {
    final comment = TextEditingController();
    var stars = 5;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.chinguCard,
              title: const Text('경기 평가', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setState(() => stars = i + 1),
                        icon: Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          color: AppColors.gold,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: comment,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '피드백을 남겨 주세요',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('등록'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      final error = context.read<ChinguProvider>().submitReview(
            userId: auth.appUser!.uid,
            userName: auth.appUser!.name,
            matchId: match.id,
            stars: stars,
            comment: comment.text,
          );
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        await auth.addRewardStack();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('평가가 등록되었고 리워드 스택이 1 증가했습니다.')),
          );
        }
      }
    }
    comment.dispose();
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    this.showReserve = false,
    this.compact = false,
  });

  final CulinaryMatch match;
  final bool showReserve;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final user = context.watch<AuthProvider>().appUser!;
    final ticket = chingu.activeTicketFor(user.uid, match.id);
    final date = DateFormat('yyyy. MM. dd').format(match.date);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
            chingu.vsTitle(match),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Meta(label: 'DATE', value: date),
              _Meta(label: 'TIME', value: match.time),
              _Meta(
                label: 'STATUS',
                value: match.isLive
                    ? 'LIVE'
                    : match.isCompleted
                        ? '종료'
                        : '예정',
                highlight: match.isLive,
                gold: !match.isLive,
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2A2A2A)),
            const SizedBox(height: 8),
            _Line(label: 'MENU', value: match.menu),
            const SizedBox(height: 8),
            _Line(label: 'VENUE', value: match.venue),
          ],
          if (showReserve) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: ticket != null
                    ? null
                    : () {
                        final error = chingu.reserveTicket(
                          userId: user.uid,
                          matchId: match.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error ?? '식권이 예약되었습니다. 현장에서 1,000원으로 발권하세요.',
                            ),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white38,
                  side: const BorderSide(color: Colors.white),
                  minimumSize: const Size.fromHeight(46),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  ticket == null
                      ? '이 경기 식권 예약'
                      : ticket.status == TicketStatus.issued
                          ? '발권 완료'
                          : '예약됨',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.label,
    required this.value,
    this.highlight = false,
    this.gold = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight
                  ? AppColors.liveRed
                  : gold
                      ? AppColors.gold
                      : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(height: 1.35)),
      ],
    );
  }
}
