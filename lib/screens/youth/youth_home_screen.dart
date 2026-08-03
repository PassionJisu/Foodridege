import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';

class YouthHomeScreen extends StatelessWidget {
  const YouthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return HomeScaffold(
      title: '잇:다',
      userName: user.name,
      roleLabel: '청년 이용자',
      onLogout: () => context.read<AuthProvider>().signOut(),
      features: const [
        FeatureTile(
          icon: Icons.qr_code_2,
          title: '출입 QR 생성',
          subtitle: '동적 QR로 냉장고 출입 (30초 유효)',
        ),
        FeatureTile(
          icon: Icons.store_mall_directory_outlined,
          title: '늘찬 라운지 지점 선택',
          subtitle: '이용할 지점을 선택합니다',
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '냉장고 현황',
          subtitle: '등록 식당 및 메뉴 재고 확인',
        ),
        FeatureTile(
          icon: Icons.shopping_cart_outlined,
          title: '예약 · 장바구니 · 결제',
          subtitle: '음식 예약 및 결제 취소',
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
        ),
        FeatureTile(
          icon: Icons.report_outlined,
          title: '신고하기',
        ),
      ],
    );
  }
}
