import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';

/// 친구카세 리뷰 작성 전용 페이지 (키오스크 발권 후 작성).
class ChinguReviewWriteScreen extends StatefulWidget {
  const ChinguReviewWriteScreen({
    super.key,
    this.initialTeamId,
    this.initialMatchId,
  });

  final String? initialTeamId;
  final String? initialMatchId;

  @override
  State<ChinguReviewWriteScreen> createState() =>
      _ChinguReviewWriteScreenState();
}

class _ChinguReviewWriteScreenState extends State<ChinguReviewWriteScreen> {
  late String? _teamId;
  String? _matchId;
  final _comment = TextEditingController();
  int _stars = 5;
  String? _photoNote;

  @override
  void initState() {
    super.initState();
    _teamId = widget.initialTeamId;
    _matchId = widget.initialMatchId;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;
    final teamId = _teamId ?? chingu.teams.first.id;
    final teamMatches =
        chingu.matches.where((m) => m.teamId == teamId).toList();

    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(title: const Text('리뷰 작성')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: teamId,
              dropdownColor: AppColors.chinguCard,
              decoration: const InputDecoration(
                labelText: '대학교',
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
              onChanged: (v) => setState(() {
                _teamId = v;
                _matchId = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('match-$teamId-$_matchId'),
              initialValue: _matchId ??
                  (teamMatches.isEmpty ? null : teamMatches.first.id),
              dropdownColor: AppColors.chinguCard,
              decoration: const InputDecoration(
                labelText: '일정',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              items: teamMatches
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(
                        '${DateFormat('M/d').format(m.date)} ${chingu.eventTitle(m)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) => setState(() => _matchId = id),
            ),
            const SizedBox(height: 8),
            ...teamMatches.map((match) {
              final unlocked = chingu.canWriteReview(user.uid, match.id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  chingu.eventTitle(match),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: Text(
                  unlocked ? '리뷰 작성 가능' : '키오스크 결제 후 작성 가능',
                  style: TextStyle(
                    color: unlocked ? AppColors.gold : Colors.white38,
                    fontSize: 12,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () {
                    final err = chingu.simulateKioskPayment(
                      userId: user.uid,
                      matchId: match.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          err ?? '키오스크 결제 완료 — 리뷰 작성이 가능합니다.',
                        ),
                      ),
                    );
                    setState(() => _matchId = match.id);
                  },
                  child: const Text(
                    '키오스크 결제 완료',
                    style: TextStyle(color: AppColors.gold, fontSize: 12),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              '별점 (0~5)',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Slider(
              value: _stars.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: '$_stars',
              activeColor: AppColors.gold,
              onChanged: (v) => setState(() => _stars = v.round()),
            ),
            Text('★ $_stars / 5', style: const TextStyle(color: AppColors.gold)),
            TextField(
              controller: _comment,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '리뷰를 작성해 주세요',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _photoNote = '사진 첨부(데모)'),
              child: Text(
                _photoNote ?? '사진 첨부 (선택)',
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.goldBright,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final matchId = _matchId ?? teamMatches.firstOrNull?.id;
                if (matchId == null) return;
                final err = chingu.submitReview(
                  userId: user.uid,
                  userName: user.name,
                  matchId: matchId,
                  stars: _stars,
                  comment: _comment.text,
                  photoNote: _photoNote,
                );
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  return;
                }
                final reward = await auth.recordReviewReward();
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.chinguCard,
                    title: const Text(
                      '리뷰가 등록되었습니다',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      reward,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('리뷰 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
