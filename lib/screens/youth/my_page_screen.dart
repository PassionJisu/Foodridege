import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'report_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 본인 이용 정보 대시보드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, size: 30, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: '총 이용 횟수', value: '${user.totalUsageCount}회'),
                    _StatItem(label: '패널티 점수', value: '${user.penaltyPoints}점', isWarning: user.penaltyPoints > 0),
                    _StatItem(label: '무료 쿠폰', value: '${user.freeMealCount}개'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('개인 정보 및 관리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            title: '계좌 관리',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.assignment_outlined,
            title: '구매/결제 내역',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.report_problem_outlined,
            title: '신고 및 문의 내역',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
          ),
          _MenuTile(
            icon: Icons.help_outline,
            title: '고객센터 / 문의하기',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => auth.signOut(),
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.isWarning = false});

  final String label;
  final String value;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
