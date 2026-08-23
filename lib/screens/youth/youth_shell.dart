import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'chingu/chingu_poster_screen.dart';
import 'foodridge/foodridge_map_screen.dart';
import 'my_page_screen.dart';
import 'vending/vending_home_screen.dart';

class YouthShell extends StatefulWidget {
  const YouthShell({super.key});

  @override
  State<YouthShell> createState() => _YouthShellState();
}

class _YouthShellState extends State<YouthShell> {
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;

    if (user.isSuspended) {
      return _SuspendedView(user: user, onLogout: auth.signOut);
    }

    const pages = [
      ChinguPosterScreen(),
      VendingHomeScreen(),
      MyPageScreen(),
      FoodridgeMapScreen(),
    ];

    final isChingu = _index == 0;
    final isVending = _index == 1;
    final isFoodridge = _index == 3;
    final darkNav = isChingu || isVending;

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
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
              color: selected
                  ? (isChingu ? AppColors.gold : AppColors.vendingAccent)
                  : Colors.white54,
            );
          }),
        ),
        child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: isChingu
            ? AppColors.chinguBlack
            : isVending
                ? AppColors.vendingBg
                : Colors.white,
        indicatorColor: isChingu
            ? AppColors.gold.withValues(alpha: 0.25)
            : isVending
                ? AppColors.vendingLeaf.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
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
              color: isVending ? AppColors.vendingAccent : AppColors.primary,
            ),
            label: '자판기',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: darkNav ? Colors.white54 : null),
            selectedIcon: const Icon(Icons.person),
            label: '마이',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, color: darkNav ? Colors.white54 : null),
            selectedIcon: Icon(
              Icons.map,
              color: isFoodridge ? AppColors.primary : null,
            ),
            label: 'Foodridge',
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
