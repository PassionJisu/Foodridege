import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/feature_tile.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inventory = context.watch<InventoryProvider>();
    final user = auth.appUser!;

    return HomeScaffold(
      title: '관리 대시보드',
      userName: user.name,
      roleLabel: '운영 관리자',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => auth.signOut(),
      features: [
        // 관리자 공지/상태 카드
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.blue.shade900,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '22:30 출근 직후 재고를 초기화하고, 00:30까지 신규 입고량을 입력해 주세요.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.refresh_rounded,
          title: '전일 재고 초기화 (22:30)',
          subtitle: '모든 상품 수량을 0으로 변경합니다',
          comingSoon: false,
          onTap: () => _confirmReset(context, inventory),
        ),
        const FeatureTile(
          icon: Icons.edit_note_rounded,
          title: '판매 수량 업데이트 (00:30)',
          subtitle: '신규 입고된 식품 수량 입력',
          comingSoon: true, // TODO: 재고 편집 화면
        ),
        const FeatureTile(
          icon: Icons.report_outlined,
          title: '신고 접수 내역',
          subtitle: '위생/시설 신고 확인 및 패널티 부여',
          comingSoon: true,
        ),
        const FeatureTile(
          icon: Icons.history_rounded,
          title: '수거 노선 점검',
          subtitle: '운송 주체별 수거 현황 확인',
          comingSoon: true,
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, InventoryProvider inventory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재고 초기화'),
        content: const Text('전일 잔여 음식을 폐기하셨나요? 모든 상품의 판매 수량이 0으로 초기화됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await inventory.resetInventory();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('초기화 실행'),
          ),
        ],
      ),
    );
  }
}
