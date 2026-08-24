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
              '잔반 수거는 없습니다. 자판기 입고 신청만 이용합니다.',
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.inventory_2_outlined,
          title: '자판기 입고 신청',
          subtitle: '끼니·품목만 등록 (지점 선택 없음)',
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
