import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '관리자 홈',
      userName: user.name,
      roleLabel: '관리자 (알바생)',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: const [
        FeatureTile(
          icon: Icons.store_mall_directory_outlined,
          title: '지점 관리',
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '냉장고 재고 관리',
        ),
        FeatureTile(
          icon: Icons.report_outlined,
          title: '신고 처리',
        ),
        FeatureTile(
          icon: Icons.block,
          title: '이용자 블랙리스트',
          subtitle: 'QR 출입 제한 관리',
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
        ),
      ],
    );
  }
}
