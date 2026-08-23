import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Firebase 없이도 데모 로그인 화면 표시', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const FoodridgeApp(firebaseConfigured: false),
      ),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('login'), findsWidgets);
    expect(find.text('register'), findsOneWidget);
  });
}
