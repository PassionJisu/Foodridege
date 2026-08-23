import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'org_supply_screen.dart';

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
              '지점 선택 없이 자판기 입고만 신청합니다. 신고 관리 메뉴는 제공하지 않습니다.',
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
      ],
    );
  }
}
