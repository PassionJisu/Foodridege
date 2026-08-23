import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/setup/firebase_setup_screen.dart';

void main() {
  testWidgets('Firebase 미설정 시 설정 안내 화면 표시', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const FoodridgeApp(firebaseConfigured: false),
      ),
    );

    expect(find.byType(FirebaseSetupScreen), findsOneWidget);
    expect(find.text('Firebase 설정 필요'), findsOneWidget);
  });
}
