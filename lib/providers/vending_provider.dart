import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/vending.dart';

class StockResult {
  const StockResult({this.error, this.assignedNumber, this.machineName});
  final String? error;
  final int? assignedNumber;
  final String? machineName;
}

class SlotAssignment {
  const SlotAssignment({
    required this.displayNumber,
    required this.machineId,
    required this.machineName,
  });

  final int displayNumber;
  final String machineId;
  final String machineName;
}

/// 환승반찬 — 기관 신청 즉시 전역 번호 1~120 + 대학 라운드로빈 배정.
class VendingProvider with ChangeNotifier {
  VendingProvider() {
    _machines = SeedData.machines.map((m) => m).toList();
    _slots.addAll([
      VendingSlot(
        id: 'demo-1',
        machineId: 'vm-jnu',
        displayNumber: 1,
        name: '멸치볶음',
        quantity: 4,
        photoAsset: 'assets/images/myeolchi.jpg',
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-2',
        machineId: 'vm-gwu',
        displayNumber: 2,
        name: '시금치나물',
        quantity: 3,
        photoAsset: 'assets/images/sigumchi.jpg',
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-nambu-1',
        machineId: 'vm-nambu',
        displayNumber: 3,
        name: '콩자반',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gju-1',
        machineId: 'vm-gju',
        displayNumber: 4,
        name: '깍두기',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-honam-1',
        machineId: 'vm-honam',
        displayNumber: 5,
        name: '제육볶음',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-chosun-1',
        machineId: 'vm-chosun',
        displayNumber: 6,
        name: '계란말이',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-jnu-2',
        machineId: 'vm-jnu',
        displayNumber: 7,
        name: '잡채',
        quantity: 3,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gwu-2',
        machineId: 'vm-gwu',
        displayNumber: 8,
        name: '고등어조림',
        quantity: 2,
        createdAt: DateTime.now(),
      ),
    ]);
    // 시드 재고 1~8 + 데모 수거 신청 예약 번호 9~11.
    // 대학은 번호 기준: 전남대 → 광주여대 → 남부대 → 광주대 → 호남대 → 조선대 반복.
    _nextGlobalNumber = 12;
  }

  static const int maxGlobalNumbers = 120;

  late List<VendingMachine> _machines;
  final List<VendingSlot> _slots = [];
  int _nextGlobalNumber = 1;

  /// 1 전남대 → 2 광주여대 → 3 남부대 → 4 광주대 → 5 호남대 → 6 조선대 → 7 전남대 …
  VendingMachine campusForNumber(int displayNumber) {
    final index = (displayNumber - 1) % _machines.length;
    return _machines[index];
  }

  List<VendingMachine> get machines => List.unmodifiable(_machines);
  List<VendingSlot> get slots => List.unmodifiable(_slots);

  int get nextGlobalNumber => _nextGlobalNumber;

  List<VendingSlot> get allSlotsSorted {
    final list = List<VendingSlot>.of(_slots);
    list.sort((a, b) => a.displayNumber.compareTo(b.displayNumber));
    return list;
  }

  VendingMachine machineById(String id) =>
      _machines.firstWhere((m) => m.id == id);

  List<VendingSlot> slotsFor(String machineId) {
    final list = _slots.where((s) => s.machineId == machineId).toList();
    list.sort((a, b) => a.displayNumber.compareTo(b.displayNumber));
    return list;
  }

  int usedSlots(String machineId) =>
      slotsFor(machineId).fold(0, (sum, s) => sum + s.quantity);

  int remainingSlots(String machineId) =>
      VendingMachine.maxSlots - usedSlots(machineId);

  /// 기관 수거 신청 시 호출. 번호·대학을 즉시 확정하고 재고 슬롯은 만들지 않음.
  SlotAssignment? reserveSlot() {
    if (_nextGlobalNumber > maxGlobalNumbers) return null;
    final displayNumber = _nextGlobalNumber;
    final machine = campusForNumber(displayNumber);
    _nextGlobalNumber += 1;
    notifyListeners();
    return SlotAssignment(
      displayNumber: displayNumber,
      machineId: machine.id,
      machineName: machine.name,
    );
  }

  /// 기사 입고: 신청 때 배정된 번호 그대로 자판기 재고에 반영.
  StockResult stockReserved({
    required int displayNumber,
    required String machineId,
    required String name,
    required int quantity,
    String? photoAsset,
    String? photoPath,
    Uint8List? photoBytes,
  }) {
    if (quantity <= 0) {
      return const StockResult(error: '수량을 입력해 주세요.');
    }
    if (_slots.any((s) => s.displayNumber == displayNumber)) {
      return StockResult(error: '이미 입고된 번호입니다. (No. $displayNumber)');
    }
    final machine = _machines.firstWhere(
      (m) => m.id == machineId,
      orElse: () => _machines.first,
    );
    _slots.add(
      VendingSlot(
        id: 'slot-${DateTime.now().millisecondsSinceEpoch}-$displayNumber',
        machineId: machine.id,
        displayNumber: displayNumber,
        name: name,
        quantity: quantity,
        photoAsset: photoAsset,
        photoPath: photoPath,
        photoBytes: photoBytes,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return StockResult(
      assignedNumber: displayNumber,
      machineName: machine.name,
    );
  }

  /// 하위 호환: 번호가 아직 없는 경우 신청과 같은 라운드로빈으로 배정 후 입고.
  StockResult stockDishGlobal({
    required String name,
    required int quantity,
    String? photoAsset,
    String? photoPath,
    Uint8List? photoBytes,
  }) {
    if (quantity <= 0) {
      return const StockResult(error: '수량을 입력해 주세요.');
    }
    final reserved = reserveSlot();
    if (reserved == null) {
      return const StockResult(error: '번호가 모두 소진되었습니다. (최대 120번)');
    }
    return stockReserved(
      displayNumber: reserved.displayNumber,
      machineId: reserved.machineId,
      name: name,
      quantity: quantity,
      photoAsset: photoAsset,
      photoPath: photoPath,
      photoBytes: photoBytes,
    );
  }

  /// 하위 호환: 기존 호출부는 전역 입고로 위임.
  String? stockDish({
    required String machineId,
    required String name,
    required int quantity,
    String? photoAsset,
  }) {
    final result = stockDishGlobal(
      name: name,
      quantity: quantity,
      photoAsset: photoAsset,
    );
    return result.error;
  }

  void disposeAllInventory() {
    _slots.clear();
    _nextGlobalNumber = 1;
    for (var i = 0; i < _machines.length; i++) {
      _machines[i] = _machines[i].copyWith(
        disposedAt: DateTime.now(),
        disposalConfirmed: true,
        clearStocking: true,
      );
    }
    notifyListeners();
  }

  String? disposeInventory(String machineId) {
    final index = _machines.indexWhere((m) => m.id == machineId);
    if (index < 0) return '자판기를 찾을 수 없습니다.';
    _slots.removeWhere((s) => s.machineId == machineId);
    _machines[index] = _machines[index].copyWith(
      disposedAt: DateTime.now(),
      disposalConfirmed: true,
      clearStocking: true,
    );
    notifyListeners();
    return null;
  }
}
