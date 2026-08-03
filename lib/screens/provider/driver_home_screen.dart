import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '기사님 홈',
      userName: user.name,
      roleLabel: '운송 기사님',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: const [
        FeatureTile(
          icon: Icons.map_outlined,
          title: '수거 지도',
          subtitle: '오늘의 수거 경로 확인',
        ),
        FeatureTile(
          icon: Icons.route,
          title: 'AI 최적 경로',
          subtitle: 'Tmap API 연동 예정',
        ),
        FeatureTile(
          icon: Icons.local_shipping_outlined,
          title: '당일 수거 목록',
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
        ),
      ],
    );
  }
}
