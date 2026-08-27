import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'chingu/free_ticket_flow.dart';
import 'my_page_screen.dart';

/// Shared home for every role. Profile opens MyPage; banners differ by role.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_background.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.85),
            errorBuilder: (_, __, ___) => Container(color: AppColors.canvas),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.canvas.withValues(alpha: 0.12),
                      AppColors.canvas.withValues(alpha: 0.5),
                      AppColors.canvas.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: Colors.black26,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MyPageScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.person_outline,
                              size: 22,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: user.role.showsUsageStats
                      ? _StudentBanner(user: user)
                      : _RoleWelcomeBanner(user: user),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentBanner extends StatelessWidget {
  const _StudentBanner({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '어서오세요, ${user.name}님! 오늘도 맛있는 식사하세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '내가 환경에 기여한 무게',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                user.contributedKgLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Chip(
                      label: '환승반찬 이용',
                      value: '${user.vendingUsageCount}회',
                    ),
                  ),
                  if (user.role.canAccessChingu) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Chip(
                        label: '친구카세 이용',
                        value: '${user.chinguUsageCount}회',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.calendar_today_outlined,
                value: '${user.usageDays}일',
                label: '이용 일수',
              ),
            ),
            if (user.role.canAccessChingu) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(
                  icon: Icons.confirmation_number_outlined,
                  value: '${user.displayCouponCount}장',
                  label: '무료 식권',
                  onTap: () => promptUseHeldFreeTickets(context),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RoleWelcomeBanner extends StatelessWidget {
  const _RoleWelcomeBanner({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final text = switch (user.role) {
      UserRole.owner =>
        '어서오세요 ${user.name}님, 당신의 배려를 ${user.helpedYouthCount}명의 청년들이 받고 있습니다.',
      UserRole.driver =>
        '어서오세요 ${user.name} 기사님, 오늘도 안전한 수거 부탁드립니다.',
      UserRole.org =>
        '어서오세요 ${user.name}님, 환승반찬 입고 신청으로 청년들의 식탁을 채워 주세요.',
      UserRole.admin => '어서오세요 ${user.name}님, 전체 운영 기능을 이용할 수 있습니다.',
      UserRole.youth => '어서오세요, ${user.name}님! 청년 회원으로 서비스를 이용할 수 있습니다.',
      UserRole.student => '어서오세요, ${user.name}님!',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4C8B4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.sage),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7A6558))),
        ],
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}
