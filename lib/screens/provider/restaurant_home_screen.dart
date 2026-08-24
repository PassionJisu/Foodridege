import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'restaurant_my_page_screen.dart';
import 'sale_history_screen.dart';

class RestaurantHomeScreen extends StatelessWidget {
  const RestaurantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeScaffold(
      title: '사장님 홈',
      userName: user.name,
      roleLabel: '점주',
      accentColor: Colors.orange.shade700,
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: [
        FeatureTile(
          icon: Icons.history_rounded,
          title: '매매 신청 내역',
          subtitle: '입고·신청 현황 및 과거 이력',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SaleHistoryScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.account_balance_wallet_outlined,
          title: '정산 내역 확인',
          subtitle: '이번 달 매매 대금 및 정산 현황',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestaurantMyPageScreen(),
              ),
            );
          },
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestaurantMyPageScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
