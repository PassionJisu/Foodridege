import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/data/org_locations.dart';
import 'package:flutter_app/data/seed_data.dart';
import 'package:flutter_app/models/sale_request.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/providers/sale_provider.dart';
import 'package:flutter_app/providers/vending_provider.dart';
import 'package:flutter_app/services/org_supply_window.dart';

void main() {
  tearDown(() {
    OrgSupplyWindow.demoForceOpen = false;
  });

  test('기관 접수는 11시부터 15시 전까지 열려 있다', () {
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 10, 59)), isFalse);
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 11)), isTrue);
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 14, 59)), isTrue);
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 15)), isFalse);
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 23, 0)), isFalse);
  });

  test('데모 강제 열기를 켜면 마감 시간에도 접수할 수 있다', () {
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 16)), isFalse);
    OrgSupplyWindow.demoForceOpen = true;
    expect(OrgSupplyWindow.isOpen(DateTime(2026, 8, 28, 16)), isTrue);
    expect(OrgSupplyWindow.statusMessage(), contains('데모 모드'));
  });

  test('15시 마감 후 다음 오픈은 다음날 11시이다', () {
    final next = OrgSupplyWindow.nextOpenAt(DateTime(2026, 8, 28, 15, 1));
    expect(next, DateTime(2026, 8, 29, 11));
    final morning = OrgSupplyWindow.nextOpenAt(DateTime(2026, 8, 28, 8));
    expect(morning, DateTime(2026, 8, 28, 11));
  });

  test('수거 신청 시 번호와 대학이 라운드로빈으로 배정된다', () {
    final vending = VendingProvider();
    const expected = [
      'vm-jnu',
      'vm-gwu',
      'vm-nambu',
      'vm-gju',
      'vm-honam',
      'vm-chosun',
    ];
    for (var n = 1; n <= 12; n++) {
      expect(vending.campusForNumber(n).id, expected[(n - 1) % 6]);
    }

    final first = vending.reserveSlot()!;
    final second = vending.reserveSlot()!;
    expect(first.displayNumber, 12);
    expect(first.machineId, 'vm-chosun');
    expect(first.machineName, '조선대 환승반찬');
    expect(second.displayNumber, 13);
    expect(second.machineId, 'vm-jnu');
    expect(second.machineName, '전남대 환승반찬');
    expect(vending.slots.where((s) => s.displayNumber == 12), isEmpty);

    final stocked = vending.stockReserved(
      displayNumber: first.displayNumber,
      machineId: first.machineId,
      name: '시금치나물',
      quantity: 4,
    );
    expect(stocked.error, isNull);
    expect(vending.slots.any((s) => s.displayNumber == 12), isTrue);
  });

  test('수거 동선은 전남대에서 시작해 신청 기관만 포함한다', () {
    final sale = SaleProvider();
    final route = OrgLocations.routeForPending(sale.pendingPickups);
    expect(route.first.name, contains('전남대학교'));
    expect(route.first.isOrigin, isTrue);
    expect(route.length, greaterThan(1));
    expect(
      route.skip(1).map((s) => s.name).toSet(),
      containsAll(['광주광역시 식자재지원센터', '광주 농식품유통센터']),
    );
    expect(route.any((s) => s.name.contains('호남대')), isFalse);
  });

  test('MealPick 가게마다 마감 시간이 있다', () {
    expect(SeedData.shops.every((s) => s.closesAt.contains(':')), isTrue);
    expect(SeedData.shops.first.openTillLabel, 'Open till 21:00');
    expect(
      SeedData.shops.map((s) => s.closesAt).toSet().length,
      greaterThan(1),
    );
  });

  test('신청 내역 시드에 슬롯 번호가 붙어 있다', () {
    final sale = SaleProvider();
    expect(
      sale.pendingPickups.every((r) => r.hasSlotAssignment),
      isTrue,
    );
    expect(sale.collectedForStocking.single.displayNumber, 11);
  });

  test('입고는 신청 때 받은 번호를 그대로 쓴다', () {
    final sale = SaleProvider();
    final vending = VendingProvider();
    final collected = sale.collectedForStocking.single;
    final result = vending.stockReserved(
      displayNumber: collected.displayNumber!,
      machineId: collected.machineId!,
      name: collected.itemLabel ?? '반찬',
      quantity: collected.quantity,
    );
    expect(result.assignedNumber, 11);
    expect(result.machineName, '호남대 환승반찬');
  });

  test('SaleRequest 상태 변경 시 슬롯 배정이 유지된다', () {
    final req = SaleRequest(
      id: 'x',
      restaurantId: 'o',
      restaurantName: '기관',
      branchName: '전남대',
      category: ProductCategory.sidedish,
      quantity: 1,
      pricePerUnit: 0,
      status: SaleRequestStatus.pending,
      createdAt: DateTime(2026, 8, 28),
      displayNumber: 20,
      machineId: 'vm-jnu',
      machineName: '전남대 환승반찬',
    );
    expect(req.copyWith(status: SaleRequestStatus.collected).displayNumber, 20);
  });
}
