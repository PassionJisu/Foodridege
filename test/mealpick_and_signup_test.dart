import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/data/seed_data.dart';
import 'package:flutter_app/models/attached_photo.dart';
import 'package:flutter_app/models/foodridge_reservation.dart';
import 'package:flutter_app/models/user_role.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/chingu_provider.dart';
import 'package:flutter_app/providers/foodridge_provider.dart';
import 'package:flutter_app/providers/vending_provider.dart';
import 'package:flutter_app/screens/auth/role_selection_screen.dart';
import 'package:flutter_app/screens/auth/signup_form_screen.dart';
import 'package:flutter_app/screens/youth/foodridge/foodridge_checkout_screen.dart';
import 'package:flutter_app/screens/youth/foodridge/mealpick_filter.dart';
import 'package:flutter_app/screens/youth/foodridge/shop_detail_screen.dart';
import 'package:flutter_app/screens/youth/my_page_screen.dart';
import 'package:flutter_app/screens/youth/youth_shell.dart';
import 'package:flutter_app/services/demo_auth_store.dart';
import 'package:flutter_app/widgets/photo_attach_field.dart';

Widget _app({required Widget child, AuthProvider? auth, FoodridgeProvider? foodridge}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth ?? AuthProvider()),
      ChangeNotifierProvider.value(value: foodridge ?? FoodridgeProvider()),
    ],
    child: MaterialApp(home: child),
  );
}

void _noopFilter(MealPickFilter value) {}

void main() {
  testWidgets('역할 선택에 청년 가입 카드가 대학생 아래에 있다', (tester) async {
    await tester.pumpWidget(_app(child: const RoleSelectionScreen()));
    expect(find.text('대학생'), findsOneWidget);
    expect(find.text('청년'), findsOneWidget);

    final studentY = tester.getTopLeft(find.text('대학생')).dy;
    final youthY = tester.getTopLeft(find.text('청년')).dy;
    expect(youthY, greaterThan(studentY));
    expect(find.text('환승반찬, 친구카세, MealPick 맵'), findsOneWidget);
    expect(find.text('환승반찬, MealPick 맵'), findsOneWidget);
  });

  test('청년은 친구카세에 접근할 수 없고 환승반찬·MealPick만 가능하다', () {
    expect(UserRole.youth.canAccessChingu, isFalse);
    expect(UserRole.youth.canAccessVending, isTrue);
    expect(UserRole.youth.canAccessFoodridge, isTrue);
    expect(UserRole.student.canAccessChingu, isTrue);
  });

  testWidgets('청년 하단 탭에 친구카세가 있고 누르면 대학생 전용 안내가 나온다', (tester) async {
    final auth = AuthProvider();
    await auth.signIn('youth@foodridge.kr', DemoAuthStore.password);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => FoodridgeProvider()),
          ChangeNotifierProvider(create: (_) => VendingProvider()),
        ],
        child: const MaterialApp(home: YouthShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('친구카세'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('환승반찬'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('MealPick'),
      ),
      findsOneWidget,
    );
    expect(find.text('환승반찬 이용'), findsOneWidget);
    expect(find.text('친구카세 이용'), findsNothing);
    expect(find.text('무료 식권'), findsNothing);
    expect(find.text('이용 일수'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('친구카세'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('접근 제한'), findsOneWidget);
    expect(find.text('대학생만 이용 가능합니다.'), findsOneWidget);
    expect(find.text('환승반찬 이용'), findsOneWidget);
  });

  testWidgets('청년 마이페이지에는 식권 기능이 없다', (tester) async {
    final auth = AuthProvider();
    await auth.signIn('youth@foodridge.kr', DemoAuthStore.password);

    await tester.pumpWidget(_app(auth: auth, child: const MyPageScreen()));
    await tester.pumpAndSettle();

    expect(find.text('무료 식권'), findsNothing);
    expect(find.textContaining('다음 식권까지'), findsNothing);
    expect(find.text('식권 예약 내역'), findsNothing);
    expect(find.text('로그아웃'), findsOneWidget);
  });

  testWidgets('대학생 마이페이지에는 식권 기능이 있다', (tester) async {
    final auth = AuthProvider();
    await auth.signIn('student@foodridge.kr', DemoAuthStore.password);

    await tester.pumpWidget(_app(auth: auth, child: const MyPageScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('무료 식권'), findsOneWidget);
    expect(find.text('식권 예약 내역'), findsOneWidget);
  });

  testWidgets('대학생 하단 탭에는 친구카세가 있다', (tester) async {
    final auth = AuthProvider();
    await auth.signIn('student@foodridge.kr', DemoAuthStore.password);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => FoodridgeProvider()),
          ChangeNotifierProvider(create: (_) => VendingProvider()),
        ],
        child: const MaterialApp(home: YouthShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('친구카세'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('환승반찬'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('MealPick'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('청년 외국인 가입은 ARC가 필수이고 학번은 없다', (tester) async {
    await tester.pumpWidget(
      _app(child: const SignupFormScreen(role: UserRole.youth)),
    );
    await tester.pumpAndSettle();

    expect(find.text('청년 회원가입'), findsOneWidget);
    expect(find.text('청년 구분'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('외국인 청년'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('외국인 청년'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('ARC (외국인등록증) 번호 *'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ARC (외국인등록증) 번호 *'), findsOneWidget);
    expect(find.text('학번 *'), findsNothing);
    expect(find.text('주민등록번호 뒷번호 1자리 *'), findsNothing);
  });

  testWidgets('대학생 외국인 가입은 학번이 필수이고 ARC는 없다', (tester) async {
    await tester.pumpWidget(
      _app(child: const SignupFormScreen(role: UserRole.student)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('외국인 (교환학생)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('외국인 (교환학생)'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('학번 *'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('학번 *'), findsOneWidget);
    expect(find.text('ARC (외국인등록증) 번호 *'), findsNothing);
  });

  testWidgets('관리자 Add menu item 다이얼로그가 레이아웃 루프 없이 열린다', (tester) async {
    final auth = AuthProvider();
    final foodridge = FoodridgeProvider();
    await auth.signIn('admin@foodridge.kr', DemoAuthStore.password);
    final shopId = foodridge.shops.first.id;

    await tester.pumpWidget(
      _app(
        auth: auth,
        foodridge: foodridge,
        child: ShopDetailScreen(shopId: shopId),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Add menu item'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add menu item'));
    await tester.pumpAndSettle();

    expect(find.text('Owner: Add menu item'), findsOneWidget);
    expect(find.text('Menu photo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Owner: Add menu item'), findsNothing);
  });

  testWidgets('사진이 있는 첨부 필드는 AlertDialog에서 무한 너비 없이 레이아웃된다', (tester) async {
    // 1x1 PNG
    final png = Uint8List.fromList(const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54,
      0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01,
      0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
      0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: SizedBox(
                      width: 360,
                      child: PhotoAttachField(
                        photo: AttachedPhoto(bytes: png),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('탭하여 사진 변경'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('식당에서 메뉴를 담으면 하단에 장바구니/예약·결제 버튼이 나온다', (tester) async {
    final auth = AuthProvider();
    final foodridge = FoodridgeProvider();
    await auth.signIn('student@foodridge.kr', DemoAuthStore.password);
    final shopId = foodridge.shops.first.id;

    await tester.pumpWidget(
      _app(
        auth: auth,
        foodridge: foodridge,
        child: ShopDetailScreen(shopId: shopId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add to cart'), findsNothing);
    expect(find.text('Book / Pay'), findsNothing);

    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(find.text('Add to cart'), findsOneWidget);
    expect(find.text('Book / Pay'), findsOneWidget);
  });

  testWidgets('결제 화면에서 현장 결제와 앱 내 결제를 고를 수 있다', (tester) async {
    final auth = AuthProvider();
    final foodridge = FoodridgeProvider();
    await auth.signIn('student@foodridge.kr', DemoAuthStore.password);
    final item = foodridge.menuItemsFor(foodridge.shops.first.id).first;
    foodridge.addToDraft(userId: auth.appUser!.uid, menuItemId: item.id);

    await tester.pumpWidget(
      _app(
        auth: auth,
        foodridge: foodridge,
        child: FoodridgeCheckoutScreen(
          source: MealPickCheckoutSource.shopDraft,
          storeId: foodridge.shops.first.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pay at store'), findsOneWidget);
    expect(find.text('Pay in app'), findsOneWidget);
    expect(find.text('Pickup is required either way.'), findsOneWidget);
  });

  test('현장 결제는 미결제 예약, 앱 내 결제는 결제 완료로 저장된다', () {
    final foodridge = FoodridgeProvider();
    const userId = 'demo-student';
    final storeId = foodridge.shops.first.id;
    final item = foodridge.menuItemsFor(storeId).first;

    foodridge.addToDraft(userId: userId, menuItemId: item.id);
    foodridge.checkoutDraft(
      userId: userId,
      storeId: storeId,
      paymentMethod: FoodridgePaymentMethod.onSite,
    );
    expect(foodridge.reservationsFor(userId).first.paid, isFalse);
    expect(
      foodridge.reservationsFor(userId).first.paymentMethod,
      FoodridgePaymentMethod.onSite,
    );

    foodridge.addToDraft(userId: userId, menuItemId: item.id);
    foodridge.checkoutDraft(
      userId: userId,
      storeId: storeId,
      paymentMethod: FoodridgePaymentMethod.inApp,
      paid: true,
    );
    expect(
      foodridge.reservationsFor(userId).any(
        (r) => r.paymentMethod == FoodridgePaymentMethod.inApp && r.paid,
      ),
      isTrue,
    );
  });

  testWidgets('기관 가입에 대표자명·기관명·사업자번호·주소가 필수이고 업태는 선택이다', (tester) async {
    await tester.pumpWidget(
      _app(child: const SignupFormScreen(role: UserRole.org)),
    );
    await tester.pumpAndSettle();

    expect(find.text('대표자명 *'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('기관명 (상호명) *'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('사업자등록번호 (또는 고유번호) *'), findsOneWidget);
    expect(find.text('기관 소재지 (주소) *'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('업태 및 종목'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('업태 및 종목'), findsOneWidget);
    expect(find.text('생년월일 *'), findsNothing);
  });

  test('My bookings에서 예약을 취소하면 목록에서 사라진다', () {
    final foodridge = FoodridgeProvider();
    const userId = 'demo-student';
    final storeId = foodridge.shops.first.id;
    final item = foodridge.menuItemsFor(storeId).first;
    foodridge.addToDraft(userId: userId, menuItemId: item.id);
    foodridge.checkoutDraft(userId: userId, storeId: storeId);
    expect(foodridge.reservationsFor(userId), isNotEmpty);
    final id = foodridge.reservationsFor(userId).first.id;
    foodridge.cancelReservation(id);
    expect(foodridge.reservationsFor(userId), isEmpty);
  });

  test('MealPick 카테고리 필터는 홈·지도에서 같은 가게를 남긴다', () {
    final shops = SeedData.shops;
    expect(
      filterMealPickShops(shops, filter: MealPickFilter.halal).map((s) => s.id),
      ['al-baraka'],
    );
    expect(
      filterMealPickShops(shops, filter: MealPickFilter.vegan).single.id,
      'green-leaf',
    );
    expect(
      filterMealPickShops(shops, filter: MealPickFilter.veget).single.id,
      'sprout-house',
    );
    expect(
      filterMealPickShops(shops, filter: MealPickFilter.chinese).single.id,
      'golden-dragon',
    );
    expect(
      filterMealPickShops(shops, filter: MealPickFilter.all).length,
      shops.length,
    );
  });

  testWidgets('MealPick 카테고리 칩은 All·Halal·Vegan·Veget·Chinese다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MealPickCategoryBar(
            selected: MealPickFilter.all,
            onChanged: _noopFilter,
            elevated: true,
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Halal'), findsOneWidget);
    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('Veget'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
  });

  test('친구카세 시드 리뷰 일부에는 사진이 첨부되어 있다', () {
    final chingu = ChinguProvider();
    final withPhoto = chingu.reviews.where((r) => r.photo?.hasImage == true);
    expect(withPhoto.length, greaterThanOrEqualTo(4));
  });
}
