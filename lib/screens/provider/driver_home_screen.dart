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
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeScaffold(
      title: '운송 관리',
      userName: user.name,
      roleLabel: '환승반찬 입고 기사님',
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
                  '신청 즉시 1~120번 · 대학 라운드로빈 배정',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '수거 후 배정된 슬롯 번호 그대로 자판기에 입고합니다.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.route_outlined,
          title: '수거 동선 확인',
          subtitle: '전남대 출발 · 신청 기관 최적 경로',
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
          title: '환승반찬 입고',
          subtitle: '배정된 슬롯 번호로 대학 자판기 입고',
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
          subtitle: '신청 대기 물품 · 배정 번호 확인',
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
