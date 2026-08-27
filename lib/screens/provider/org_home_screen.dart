import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'org_supply_screen.dart';
import 'sale_history_screen.dart';

class OrgHomeScreen extends StatelessWidget {
  const OrgHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeScaffold(
      title: '기관 홈',
      userName: user.displayOrgName,
      roleLabel: '공공 · 지원 기관',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: [
        const Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '오전 11시~오후 3시 수거 신청. 신청 즉시 자판기 번호가 배정됩니다.',
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.inventory_2_outlined,
          title: '잔반 수거 신청',
          subtitle: '오전 11시~오후 3시 · 번호·대학 자동 배정',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrgSupplyScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.history_rounded,
          title: '매매 신청 내역',
          subtitle: '입고 신청 현황 확인',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SaleHistoryScreen()),
            );
          },
        ),
      ],
    );
  }
}
