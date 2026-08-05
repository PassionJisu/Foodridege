import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'lounge_selection_screen.dart';
import 'cart_screen.dart';
import 'report_screen.dart';
import 'my_page_screen.dart';

class YouthHomeScreen extends StatelessWidget {
  const YouthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;

    // 이용 정지 체크
    if (user.isSuspended) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  '이용 정지 상태입니다',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '패널티 누적으로 인해 6개월간 이용이 제한됩니다.\n해제 일시: ${user.suspendedUntil.toString().split('.')[0]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => auth.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomeScaffold(
      title: '잇:다',
      userName: user.name,
      roleLabel: '청년 이용자',
      onLogout: () => auth.signOut(),
      features: [
        // 스트릭 및 보상 정보 카드
        Card(
          margin: const EdgeInsets.all(0),
          color: Colors.blue.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '쿠폰 발급까지 ${3 - user.purchaseDayCount}일 남았어요!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '누적 3일 구매 시 1끼 무료 쿠폰 증정 (현재 ${user.freeMealCount}개 보유)',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FeatureTile(
          icon: Icons.qr_code_2,
          title: '출입 QR 생성',
          subtitle: '입구에 QR을 스캔해 주세요',
          comingSoon: false,
          onTap: () => _showQrDialog(context, user.uid),
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '음식 예약하기',
          subtitle: '지점별 식당 재고 확인 및 예약',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoungeSelectionScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.shopping_cart_outlined,
          title: '나의 주문 내역 (장바구니)',
          subtitle: '결제 대기 중인 예약 목록',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.report_outlined,
          title: '신고 및 문의하기',
          subtitle: '위생, 시설 문제 신고 및 포상',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.person_outline,
          title: '마이페이지',
          subtitle: '이용 통계 및 개인 정보 관리',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPageScreen()),
            );
          },
        ),
      ],
    );
  }

  void _showQrDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('출입 인증 QR'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: QrImageView(
              data: uid,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
