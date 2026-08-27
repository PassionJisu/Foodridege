import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/access_gate.dart';
import 'chingu/chingu_poster_screen.dart';
import 'foodridge/foodridge_home_screen.dart';
import 'home_screen.dart';
import 'vending/vending_home_screen.dart';

/// Same shell for all roles; destinations are gated by [UserRole] permissions.
class YouthShell extends StatefulWidget {
  const YouthShell({super.key});

  @override
  State<YouthShell> createState() => _YouthShellState();
}

class _YouthShellState extends State<YouthShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    ChinguPosterScreen(),
    VendingHomeScreen(),
    FoodridgeHomeScreen(),
  ];

  Future<void> _onSelect(int value, UserRole role) async {
    if (value == 1 && !role.canAccessChingu) {
      await showAccessDenied(context, chinguStudentOnlyMessage);
      return;
    }
    if (value == 2 && !role.canAccessVending) {
      await showAccessDenied(context, '자판기 메뉴에 대한 권한이 없습니다.');
      return;
    }
    if (value == 3 && !role.canAccessFoodridge) {
      await showAccessDenied(context, 'MealPick은 현재 역할에서 이용할 수 없어요.');
      return;
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;

    // AuthGate가 LoginScreen으로 전환하긴 하지만, 로그아웃 직후 한 프레임에서
    // null이 들어가면 '!' 크래시가 날 수 있어 방어 코드를 둡니다.
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user.isSuspended) {
      return _SuspendedView(user: user, onLogout: auth.signOut);
    }

    final role = user.role;
    final isChingu = _index == 1;
    final isFoodridge = _index == 3;
    final darkNav = isChingu;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            if (!darkNav) {
              return TextStyle(
                fontSize: 12,
                color: selected ? AppColors.primary : Colors.black54,
              );
            }
            return TextStyle(
              fontSize: 12,
              color: selected ? AppColors.gold : Colors.white54,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => _onSelect(value, role),
          backgroundColor: isChingu ? AppColors.chinguBlack : AppColors.canvas,
          indicatorColor: isChingu
              ? AppColors.gold.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: darkNav ? Colors.white54 : null),
              selectedIcon: Icon(
                Icons.home,
                color: darkNav ? Colors.white : AppColors.primary,
              ),
              label: '홈',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu, color: darkNav ? Colors.white54 : null),
              selectedIcon: Icon(
                Icons.restaurant_menu,
                color: isChingu ? AppColors.gold : AppColors.primary,
              ),
              label: '친구카세',
            ),
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined, color: darkNav ? Colors.white54 : null),
              selectedIcon: Icon(
                Icons.kitchen,
                color: darkNav ? Colors.white : AppColors.primary,
              ),
              label: '환승반찬',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: darkNav ? Colors.white54 : null),
              selectedIcon: Icon(
                Icons.map,
                color: isFoodridge ? AppColors.primary : AppColors.primary,
              ),
              label: 'MealPick',
            ),
          ],
        ),
      ),
    );
  }
}

class _SuspendedView extends StatelessWidget {
  const _SuspendedView({required this.user, required this.onLogout});

  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                '패널티 누적으로 인해 6개월간 이용이 제한됩니다.\n해제 일시: ${user.suspendedUntil.toString().split('.').first}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: onLogout, child: const Text('로그아웃')),
            ],
          ),
        ),
      ),
    );
  }
}
