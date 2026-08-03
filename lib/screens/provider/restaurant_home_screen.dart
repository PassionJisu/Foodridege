import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';

class RestaurantHomeScreen extends StatelessWidget {
  const RestaurantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '사장님 홈',
      userName: user.name,
      roleLabel: '음식점 사장님',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: const [
        FeatureTile(
          icon: Icons.restaurant_menu,
          title: '메뉴 등록 · 관리',
          subtitle: '냉장고에 등록할 음식 관리',
        ),
        FeatureTile(
          icon: Icons.inventory_2_outlined,
          title: '재고 현황',
        ),
        FeatureTile(
          icon: Icons.local_shipping_outlined,
          title: '당일 수거 신청',
          subtitle: '21:00~21:30 수거 신청',
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
        ),
      ],
    );
  }
}
