import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'driver_pickup_list_screen.dart';
import 'driver_pickup_route_screen.dart';
import 'driver_stocking_screen.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '운송 관리',
      userName: user.name,
      roleLabel: '자판기 입고 기사님',
      accentColor: Colors.teal.shade700,
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.teal.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '점심 이후 1회 수거 · 출발 전 전날 재고 전량 폐기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '검수 과정 없이 사진·수량 입력 후 번호를 부여해 입고합니다.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.route_outlined,
          title: '수거 동선 확인',
          subtitle: '오늘 광주 01구역 정차 지점',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverPickupRouteScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '자판기 입고 · 번호 부여',
          subtitle: '사진/반찬명 입력, 1–20 번호, 입고 마무리',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverStockingScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.checklist_rtl_rounded,
          title: '수거 대상 목록',
          subtitle: '학생식당 잔반 · B급 농산물 보충분',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverPickupListScreen()),
            );
          },
        ),
      ],
    );
  }
}
