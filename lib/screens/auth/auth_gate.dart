import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../provider/admin_home_screen.dart';
import '../provider/driver_home_screen.dart';
import '../provider/restaurant_home_screen.dart';
import '../youth/youth_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown || auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.status == AuthStatus.unauthenticated || auth.appUser == null) {
      return const LoginScreen();
    }

    return _HomeByRole(role: auth.appUser!.role);
  }
}

class _HomeByRole extends StatelessWidget {
  const _HomeByRole({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.youth:
        return const YouthShell();
      case UserRole.restaurantOwner:
        return const RestaurantHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
    }
  }
}
