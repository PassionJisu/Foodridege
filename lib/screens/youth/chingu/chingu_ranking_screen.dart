import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';

class ChinguRankingScreen extends StatelessWidget {
  const ChinguRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final teams = chingu.rankedTeams;

    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(title: const Text('응원하기')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '광주 ✕ 전남 조리학과가 한 팀씩 돌아가며 키친을 엽니다.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              '하루 1회만 응원할 수 있습니다.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ...teams.asMap().entries.map((e) {
              final team = e.value;
              return ListTile(
                leading: Text(
                  '${e.key + 1}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
                title: Text(team.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${team.schoolName} · ${team.cheers} 응원',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: TextButton(
                  onPressed: () {
                    final err = chingu.cheer(team.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err ?? '응원 완료!')),
                    );
                  },
                  child: const Text('응원', style: TextStyle(color: AppColors.gold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
