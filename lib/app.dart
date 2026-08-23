import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/auth/auth_gate.dart';
import 'screens/setup/firebase_setup_screen.dart';
import 'theme/app_theme.dart';

class FoodridgeApp extends StatelessWidget {
  const FoodridgeApp({super.key, this.firebaseConfigured = true});

  final bool firebaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: firebaseConfigured
          ? const AuthGate()
          : const FirebaseSetupScreen(),
    );
  }
}
