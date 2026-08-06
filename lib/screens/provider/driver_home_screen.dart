import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';

import 'driver_pickup_list_screen.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '운송 관리',
      userName: user.name,
      roleLabel: '수거 전문 요원 (소셜 세이버)',
      accentColor: Colors.teal.shade700,
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: [
        // 수거 노선 요약 정보
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.teal.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 수거 노선: [광주 01구역]',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '수거 시작: 22:00 | 목표 시간: 90분 이내',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const FeatureTile(
          icon: Icons.map_outlined,
          title: '수거 노선도 확인',
          subtitle: '신청 업체 정차 지점 확인',
          comingSoon: true,
        ),
        FeatureTile(
          icon: Icons.checklist_rtl_rounded,
          title: '수거 대상 목록 (21:30 확정)',
          subtitle: '당일 수거 신청 업체 리스트',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverPickupListScreen()),
            );
          },
        ),
        const FeatureTile(
          icon: Icons.stars_rounded,
          title: '활동 보상 내역',
          subtitle: '지급 예정 식사 포인트 확인',
          comingSoon: true,
        ),
      ],
    );
  }
}
