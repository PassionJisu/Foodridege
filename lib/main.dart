import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/naver_config.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chingu_provider.dart';
import 'providers/foodridge_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'providers/report_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/vending_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

  try {
    await FlutterNaverMap().init(
      clientId: NaverConfig.clientId,
      onAuthFailed: (ex) {
        debugPrint('Naver Map auth failed: $ex');
      },
    );
  } catch (e) {
    debugPrint('Naver Map init skipped: $e');
  }

  var firebaseConfigured = false;
  try {
    if (DefaultFirebaseOptions.isConfigured) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseConfigured = true;
    }
  } catch (_) {
    firebaseConfigured = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider();
            provider.initialize();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => ChinguProvider()),
        ChangeNotifierProvider(create: (_) => VendingProvider()),
        ChangeNotifierProvider(create: (_) => FoodridgeProvider()),
      ],
      child: FoodridgeApp(firebaseConfigured: firebaseConfigured),
    ),
  );
}
