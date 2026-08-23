import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/feature_tile.dart';
import 'admin_report_manage_screen.dart';
import 'driver_stocking_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;

    return HomeScaffold(
      title: '관리 대시보드',
      userName: user.name,
      roleLabel: '운영 관리자',
      accentColor: const Color(0xFF1565C0),
      onLogout: () => auth.signOut(),
      features: [
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
                    '검수는 하지 않습니다. 기사님이 입고 마무리한 시점부터 24시간 후 전량 폐기입니다.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        FeatureTile(
          icon: Icons.kitchen_outlined,
          title: '자판기 입고 · 폐기',
          subtitle: '지점별 슬롯(최대 20) 및 폐기 확인 표',
          comingSoon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverStockingScreen()),
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
              MaterialPageRoute(builder: (_) => const AdminReportManageScreen()),
            );
          },
        ),
      ],
    );
  }
}
