import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/chingu.dart';
import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';

class ChinguRankingScreen extends StatelessWidget {
  const ChinguRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(title: const Text('응원하기')),
        body: const CheerRankingBoard(),
      ),
    );
  }
}

/// 중계식 라이브 랭킹 — 행이 순위에 따라 미끄러지고, 데모 응원으로 순위가 움직인다.
class CheerRankingBoard extends StatefulWidget {
  const CheerRankingBoard({super.key});

  @override
  State<CheerRankingBoard> createState() => _CheerRankingBoardState();
}

class _CheerRankingBoardState extends State<CheerRankingBoard> {
  static const _rowH = 92.0;

  final _rng = Random();
  Timer? _crowdTimer;
  Map<String, int> _prevRank = {};
  Map<String, int> _delta = {};
  String? _flashTeamId;
  String? _feed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _snapshotRanks(context.read<ChinguProvider>());
      _crowdTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _simulateCrowdCheer();
      });
    });
  }

  @override
  void dispose() {
    _crowdTimer?.cancel();
    super.dispose();
  }

  void _snapshotRanks(ChinguProvider chingu) {
    final ranked = chingu.rankedTeams;
    _prevRank = {
      for (var i = 0; i < ranked.length; i++) ranked[i].id: i + 1,
    };
  }

  void _applyRankShift(ChinguProvider chingu) {
    final ranked = chingu.rankedTeams;
    final nextDelta = <String, int>{};
    for (var i = 0; i < ranked.length; i++) {
      final id = ranked[i].id;
      final now = i + 1;
      final prev = _prevRank[id] ?? now;
      nextDelta[id] = prev - now;
    }
    _snapshotRanks(chingu);
    setState(() => _delta = nextDelta);
  }

  void _simulateCrowdCheer() {
    if (!mounted) return;
    final chingu = context.read<ChinguProvider>();
    final teams = chingu.teams;
    if (teams.isEmpty) return;

    _snapshotRanks(chingu);
    final team = teams[_rng.nextInt(teams.length)];
    final amount = 5 + _rng.nextInt(11);
    chingu.addCrowdCheers(team.id, amount);
    _applyRankShift(chingu);
    setState(() {
      _flashTeamId = team.id;
      _feed = '${team.schoolName}  +$amount';
    });
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && _flashTeamId == team.id) {
        setState(() => _flashTeamId = null);
      }
    });
  }

  void _cheer(CulinaryTeam team) {
    final chingu = context.read<ChinguProvider>();
    if (!chingu.canCheerToday(team.id)) {
      _showOncePerDayDialog();
      return;
    }
    _snapshotRanks(chingu);
    final from = _prevRank[team.id] ?? 0;
    final err = chingu.cheer(team.id);
    if (err != null) {
      _showOncePerDayDialog();
      return;
    }
    HapticFeedback.mediumImpact();
    _applyRankShift(chingu);
    final to = chingu.rankedTeams.indexWhere((t) => t.id == team.id) + 1;
    setState(() {
      _flashTeamId = team.id;
      _feed = to < from
          ? '${team.name}  $from위 → $to위'
          : '${team.name}에 응원 +1';
    });
  }

  void _showOncePerDayDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.chinguCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.chinguBorder),
        ),
        title: const Text(
          '하루에 1곳만 응원할 수 있어요!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          '응원은 하루에 한 요리팀만 가능합니다. 내일 다시 참여해 주세요.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldBright,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final ranked = chingu.rankedTeams;
    final maxCheers = ranked.isEmpty ? 1 : ranked.first.cheers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const _LiveBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Text(
                    _feed ?? '실시간 응원 순위가 움직입니다',
                    key: ValueKey(_feed ?? 'idle'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '하루 1회 응원 · 순위가 바뀌면 팀이 자리를 바꿉니다',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              height: ranked.length * _rowH,
              child: Stack(
                children: [
                  for (final team in chingu.teams)
                    AnimatedPositioned(
                      key: ValueKey(team.id),
                      duration: const Duration(milliseconds: 720),
                      curve: Curves.easeInOutCubic,
                      top: ranked.indexWhere((t) => t.id == team.id) * _rowH,
                      left: 0,
                      right: 0,
                      height: _rowH - 8,
                      child: _RankRow(
                        rank: ranked.indexWhere((t) => t.id == team.id) + 1,
                        team: ranked.firstWhere((t) => t.id == team.id),
                        maxCheers: maxCheers,
                        delta: _delta[team.id] ?? 0,
                        flashing: _flashTeamId == team.id,
                        cheered: chingu.alreadyCheeredToday(team.id),
                        onCheer: () => _cheer(team),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.liveRed.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.35, end: 1).animate(_pulse),
            child: const Icon(Icons.circle, size: 8, color: AppColors.liveRed),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.liveRed,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.team,
    required this.maxCheers,
    required this.delta,
    required this.flashing,
    required this.cheered,
    required this.onCheer,
  });

  final int rank;
  final CulinaryTeam team;
  final int maxCheers;
  final int delta;
  final bool flashing;
  final bool cheered;
  final VoidCallback onCheer;

  Color get _rankColor {
    return switch (rank) {
      1 => AppColors.goldBright,
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => Colors.white54,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ratio = maxCheers == 0 ? 0.0 : team.cheers / maxCheers;
    return AnimatedScale(
      duration: const Duration(milliseconds: 280),
      scale: flashing ? 1.015 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: flashing
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.chinguCard,
          border: Border.all(
            color: flashing ? AppColors.goldBright : AppColors.chinguBorder,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _rankColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: delta == 0
                  ? const Text(
                      '–',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    )
                  : Text(
                      delta > 0 ? '▲$delta' : '▼${delta.abs()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: delta > 0
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFF87171),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${team.schoolName}  ·  ${team.cheers}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.white10,
                      color: _rankColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: cheered ? null : onCheer,
              child: Text(
                cheered ? '완료' : '응원',
                style: TextStyle(
                  color: cheered ? Colors.white38 : AppColors.goldBright,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
