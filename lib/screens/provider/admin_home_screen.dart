import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/feature_tile.dart';

import 'admin_report_manage_screen.dart';
import 'admin_stocking_manage_screen.dart';

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
        FeatureTile(
          icon: Icons.data_saver_on_rounded,
          title: '데모 데이터 생성 (1호점)',
          subtitle: '식당 5곳 및 메뉴 5종 자동 추가',
          comingSoon: false,
          onTap: () => _confirmSeed(context, inventory),
        ),
        FeatureTile(
          icon: Icons.edit_note_rounded,
          title: '판매 수량 업데이트 (00:30)',
          subtitle: '수거된 식품 냉장고 재고로 등록',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminStockingManageScreen()),
            );
          },
        ),
        FeatureTile(
          icon: Icons.report_outlined,
          title: '신고 접수 내역',
          subtitle: '위생/시설 신고 확인 및 패널티 부여',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminReportManageScreen()),
            );
          },
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

  void _confirmSeed(BuildContext context, InventoryProvider inventory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데모 데이터 생성'),
        content: const Text('늘찬 라운지 1호점에 테스트용 식당 5곳과 메뉴 5종을 추가하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await inventory.seedDemoData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('데모 데이터가 생성되었습니다!')),
                );
              }
            },
            child: const Text('생성하기'),
          ),
        ],
      ),
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
