import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import 'chingu_hub_screen.dart';
import 'free_ticket_flow.dart';

class ChinguPosterScreen extends StatelessWidget {
  const ChinguPosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coupons = context.watch<AuthProvider>().appUser?.displayCouponCount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.chinguBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/chingu_poster.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.chinguBlack),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () => promptUseHeldFreeTickets(context),
                        child: _CouponBadge(count: coupons),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: const Text(
                      '2026  ·  지역 조리학과 외식 키친',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '친구카세',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '광주 ✕ 전남 조리학과',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '우리 지역 조리학과 학생들이 펼치는 외식 키친',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openHub(context, 0),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            minimumSize: const Size.fromHeight(48),
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: const Text('일정 및 식권 예약'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _openHub(context, 1),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.goldBright,
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(48),
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: const Text('응원하기'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PosterStat(value: '6', label: '참가팀'),
                      _PosterStat(value: '2', label: '지역'),
                      _PosterStat(value: '9–12월', label: '운영 기간'),
                      _PosterStat(value: '100장', label: '학교 당 식권'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHub(BuildContext context, int tab) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChinguHubScreen(initialTab: tab)),
    );
  }
}

class _CouponBadge extends StatelessWidget {
  const _CouponBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '쿠폰 $count',
        style: const TextStyle(color: AppColors.gold, fontSize: 12),
      ),
    );
  }
}

class _PosterStat extends StatelessWidget {
  const _PosterStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
