import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

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
    ChangeNotifierProvider(
      create: (_) {
        final provider = AuthProvider();
        if (firebaseConfigured) {
          provider.initialize();
        }
        return provider;
      },
      child: ItdaApp(firebaseConfigured: firebaseConfigured),
    ),
  );
}
