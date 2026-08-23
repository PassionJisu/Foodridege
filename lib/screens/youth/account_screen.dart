import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('계좌 관리')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DCC8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('정산 · 환불 계좌', style: TextStyle(color: Color(0xFF8A7466))),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('광주은행', style: TextStyle(fontWeight: FontWeight.w600)),
                const Text('123-456-789012'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '데모 모드에서는 실제 이체가 이루어지지 않습니다. 키오스크 발권·자판기 현장 결제와 연동될 계좌입니다.',
            style: TextStyle(color: Color(0xFF8A7466), height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데모 계좌 정보가 저장되었습니다.')),
              );
            },
            child: const Text('계좌 정보 저장'),
          ),
        ],
      ),
    );
  }
}
