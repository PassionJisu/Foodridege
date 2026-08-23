import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'admin_report_manage_screen.dart';
import 'driver_stocking_screen.dart';

class OrgHomeScreen extends StatelessWidget {
  const OrgHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '기관 홈',
      userName: user.name,
      roleLabel: '공공 · 지원 기관',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: [
        const Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '지역 식자재 순환과 친구카세 운영을 지원합니다. 자판기 입고·폐기 현황을 확인할 수 있습니다.',
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '자판기 입고 · 폐기 현황',
          subtitle: '지점별 슬롯 및 폐기 확인',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverStockingScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.report_outlined,
          title: '신고 내역',
          subtitle: '위생·시설 신고 확인',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReportManageScreen()),
            );
          },
        ),
      ],
    );
  }
}
