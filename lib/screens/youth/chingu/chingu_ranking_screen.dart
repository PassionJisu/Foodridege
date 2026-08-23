import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chingu_provider.dart';
import '../../../theme/app_theme.dart';

class ChinguRankingScreen extends StatelessWidget {
  const ChinguRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chingu = context.watch<ChinguProvider>();
    final ranked = chingu.rankedTeams;

    return Theme(
      data: AppTheme.chinguDark,
      child: Scaffold(
        backgroundColor: AppColors.chinguBlack,
        appBar: AppBar(
          title: const Text('경쟁 대시보드'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '친구 응원하기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              '광주 · 전남 조리학과와 대전 조리학과가 한 팀씩 돌아가며 자존심을 겁니다.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 20),
            ...List.generate(ranked.length, (index) {
              final team = ranked[index];
              final cheered = chingu.alreadyCheered(team.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: index == 0 ? AppColors.gold : AppColors.chinguBorder,
                  ),
                  color: const Color(0xFF141414),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? AppColors.gold : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            team.region,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${team.cheers}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: cheered
                          ? null
                          : () {
                              final error = chingu.cheer(team.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error ?? '${team.name}을 응원했습니다!')),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        disabledForegroundColor: Colors.white24,
                        side: BorderSide(
                          color: cheered ? Colors.white24 : AppColors.gold,
                        ),
                        minimumSize: const Size(72, 36),
                      ),
                      child: Text(cheered ? '완료' : '응원'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
