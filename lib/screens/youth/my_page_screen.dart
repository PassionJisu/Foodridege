import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/foodridge_logo.dart';
import '../provider/driver_pickup_route_screen.dart';
import '../youth/report_screen.dart';
import 'account_screen.dart';
import 'chingu/ticket_history_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;
    final grams = user.contributedGrams;
    final isDriver = user.role == UserRole.driver;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/mypage_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          Container(color: AppColors.canvas.withValues(alpha: 0.72)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: FoodridgeLogo(height: 52),
                ),
                const SizedBox(height: 20),
                Text(
                  '반갑습니다, ${user.name}님.',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '끼니 거르지 마세요.\n오늘도 맛있는 식사하세요.\n광주시가 지원합니다.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF6A5346),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '내가 환경에 기여한 무게',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatGrams(grams)} g',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                      Text(
                        '자판기 이용 ${user.vendingUsageCount}회 × 200g',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _CountChip(
                              label: '자판기 이용',
                              value: '${user.vendingUsageCount}회',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _CountChip(
                              label: '친구카세 이용',
                              value: '${user.chinguUsageCount}회',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: '이용 일수',
                        value: '${user.usageDays}일',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: '쌓인 리워드',
                        value: '${user.rewardStack}',
                        icon: Icons.stars_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: '외식 쿠폰',
                        value: '${user.displayCouponCount}장',
                        icon: Icons.confirmation_number_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  '계정',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
                _MenuTile(
                  icon: Icons.account_balance_outlined,
                  title: '계좌 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                ),
                _MenuTile(
                  icon: Icons.confirmation_number_outlined,
                  title: '식권 예약 내역',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TicketHistoryScreen()),
                    );
                  },
                ),
                if (isDriver)
                  _MenuTile(
                    icon: Icons.route_outlined,
                    title: '수거 동선 확인',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverPickupRouteScreen(),
                        ),
                      );
                    },
                  ),
                _MenuTile(
                  icon: Icons.logout,
                  title: '로그아웃',
                  danger: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
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
                    if (confirmed == true && context.mounted) {
                      auth.signOut();
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '고객지원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
                _MenuTile(
                  icon: Icons.report_problem_outlined,
                  title: '문의 및 신고',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatGrams(int grams) {
    if (grams >= 1000) {
      return grams.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return '$grams';
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.sage),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A7466))),
        ],
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
