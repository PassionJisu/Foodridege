import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import '../../widgets/role_card.dart';
import 'signup_form_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원 유형 선택')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '가입 유형을 선택해 주세요',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '유형에 따라 이용 가능한 기능이 달라집니다. 관리자 가입에는 시크릿 키가 필요합니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '일반 사용자',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.student,
            icon: Icons.school_outlined,
            description: '환승반찬, 친구카세, MealPick 맵',
            onTap: () => _goToSignup(context, UserRole.student),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.youth,
            icon: Icons.volunteer_activism_outlined,
            description: '환승반찬, MealPick 맵',
            onTap: () => _goToSignup(context, UserRole.youth),
          ),
          const SizedBox(height: 24),
          Text(
            '공급자 / 운영',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.owner,
            icon: Icons.storefront_outlined,
            description: 'MealPick 가게 · 메뉴 등록',
            onTap: () => _goToSignup(context, UserRole.owner),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.org,
            icon: Icons.account_balance_outlined,
            description: '자판기 입고 신청 (지점 선택 없음)',
            onTap: () => _goToSignup(context, UserRole.org),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.driver,
            icon: Icons.local_shipping_outlined,
            description: '네이버맵 수거 동선, 환승반찬 입고',
            onTap: () => _goToSignup(context, UserRole.driver),
          ),
          const SizedBox(height: 12),
          RoleCard(
            role: UserRole.admin,
            icon: Icons.admin_panel_settings_outlined,
            description: '모든 기능 이용 · 신고 관리',
            onTap: () => _goToSignup(context, UserRole.admin),
          ),
        ],
      ),
    );
  }

  void _goToSignup(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignupFormScreen(role: role),
      ),
    );
  }
}
