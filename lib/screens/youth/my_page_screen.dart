import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../provider/admin_report_manage_screen.dart';
import '../provider/driver_pickup_list_screen.dart';
import '../provider/driver_pickup_route_screen.dart';
import '../provider/driver_stocking_screen.dart';
import '../provider/org_supply_screen.dart';
import '../provider/sale_history_screen.dart';
import 'account_screen.dart';
import 'chingu/free_ticket_flow.dart';
import 'chingu/ticket_history_screen.dart';
import 'report_screen.dart';

/// Profile / account menus only. Home stats live on [HomeScreen].
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    // 로그아웃 직후 Provider 알림으로 rebuild될 때 null 방어
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final role = user.role;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: AppColors.canvas,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '${user.name}님',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role.label,
            style: const TextStyle(color: Color(0xFF8A7466), fontSize: 14),
          ),
          if (role == UserRole.org && user.orgName != null) ...[
            const SizedBox(height: 2),
            Text(
              user.orgName!,
              style: const TextStyle(color: Color(0xFF8A7466), fontSize: 13),
            ),
          ],
          if (role.canAccessChingu) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.canvasDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => promptUseHeldFreeTickets(context),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    const Icon(Icons.stars_outlined, color: AppColors.sage),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '리뷰 ${user.reviewCount}회 · 다음 식권까지 '
                        '${user.reviewsToNextCoupon}회',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '무료 식권 ${user.displayCouponCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.sage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const _SectionTitle('계정'),
          if (role.canAccessChingu || role == UserRole.admin)
            _MenuTile(
              icon: Icons.account_balance_outlined,
              title: '계좌 관리',
              onTap: () => _push(context, const AccountScreen()),
            ),
          if (role.canAccessChingu)
            _MenuTile(
              icon: Icons.confirmation_number_outlined,
              title: '식권 예약 내역',
              onTap: () => _push(context, const TicketHistoryScreen()),
            ),
          if (role.canSubmitSupply) ...[
            _MenuTile(
              icon: Icons.inventory_2_outlined,
              title: '잔반 수거 신청',
              onTap: () => _push(context, const OrgSupplyScreen()),
            ),
            _MenuTile(
              icon: Icons.history_rounded,
              title: '수거 신청 내역',
              onTap: () => _push(context, const SaleHistoryScreen()),
            ),
          ],
          if (role.canViewPickupRoute)
            _MenuTile(
              icon: Icons.route_outlined,
              title: '수거 동선 (네이버맵)',
              onTap: () => _push(context, const DriverPickupRouteScreen()),
            ),
          if (role.canManageVending) ...[
            _MenuTile(
              icon: Icons.kitchen_outlined,
              title: '환승반찬 입고 · 배정 번호',
              onTap: () => _push(context, const DriverStockingScreen()),
            ),
            _MenuTile(
              icon: Icons.checklist_rtl_rounded,
              title: '수거 대상 목록',
              onTap: () => _push(context, const DriverPickupListScreen()),
            ),
          ],
          if (role.canManageReports)
            _MenuTile(
              icon: Icons.report_outlined,
              title: '신고 접수 관리',
              onTap: () => _push(context, const AdminReportManageScreen()),
            ),
          _MenuTile(
            icon: Icons.logout,
            title: '로그아웃',
            danger: true,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                // 스택을 먼저 정리한 뒤 로그아웃 → 중간 rebuild에서 null 크래시 방지
                Navigator.of(context).popUntil((route) => route.isFirst);
                await auth.signOut();
              }
            },
          ),
          if (role.canUseSupport) ...[
            const SizedBox(height: 16),
            const _SectionTitle('고객지원'),
            _MenuTile(
              icon: Icons.report_problem_outlined,
              title: '문의 및 신고',
              onTap: () => _push(context, const ReportScreen()),
            ),
          ],
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: danger ? Colors.red : AppColors.ink),
      title: Text(
        title,
        style: TextStyle(color: danger ? Colors.red : AppColors.ink),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.ink),
      onTap: onTap,
    );
  }
}
