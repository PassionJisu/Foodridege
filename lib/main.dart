import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'providers/report_provider.dart';
import 'providers/sale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

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
            if (firebaseConfigured) {
              provider.initialize();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      child: ItdaApp(firebaseConfigured: firebaseConfigured),
    ),
  );
}
